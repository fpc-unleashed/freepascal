#!/usr/bin/env bash
# Codegen assertion for -OoIPARA (interprocedural register allocation).
#
# The runtime tests under testfiles/optipara/ prove -OoIPARA is semantics-
# preserving; this script proves it actually REDUCES caller-save pressure.
# A caller that keeps several values live across a call to a small leaf helper
# is forced, under the full ABI mask, to evacuate them into callee-saved
# registers (push/pop %rbx/%r12/%r13/%r14). With -OoIPARA the helper's proven
# clobber set is small, so those values stay in untouched volatile registers
# and the callee-saved pushes disappear. We inspect the emitted assembly
# (-al -s) because the byte-based %CHECKBIN_* directives cannot match register
# names.
#
# Usage: unleashed/tests/ipara_codegen_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/k.pp" <<'EOF'
program k;
{$mode objfpc}
function addone(x: longint): longint;
begin addone:=x+1; end;
function hot(a,b,c,d: longint): longint;
var s: longint;
begin
  s:=a*2;
  s:=s+addone(b);
  s:=s+a; s:=s+c; s:=s+d;
  hot:=s;
end;
begin
  writeln(hot(10,20,30,40));
end.
EOF

mkdir -p "$tmp/on" "$tmp/off"
cp "$tmp/k.pp" "$tmp/on/"; cp "$tmp/k.pp" "$tmp/off/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O2 -OoIPARA -al -s k.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O2          -al -s k.pp >/dev/null 2>&1 )

# count callee-saved register pushes inside hot()
csregs='push[ql]?[[:space:]]+%(rbx|r12|r13|r14|r15)'
on_saves=$( sed -n '/_HOT\$/,/\.size.*_HOT\$/p' "$tmp/on/k.s"  | grep -Eci "$csregs" || true)
off_saves=$(sed -n '/_HOT\$/,/\.size.*_HOT\$/p' "$tmp/off/k.s" | grep -Eci "$csregs" || true)

echo "ON  -OoIPARA : callee-saved pushes in hot = $on_saves"
echo "OFF          : callee-saved pushes in hot = $off_saves"

rc=0
[ "$off_saves" -ge 3 ] || { echo "FAIL: expected the caller to spill to callee-saved regs with IPARA off"; rc=1; }
[ "$on_saves" -lt "$off_saves" ] || { echo "FAIL: -OoIPARA did not reduce caller-save pressure"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: -OoIPARA keeps caller values in untouched volatile registers across the call"

# --------------------------------------------------------------------------
# Cross-unit case (shared per-procdef PPU optimizer-summary mechanism): the
# leaf helper lives in a separate unit whose ppu carries ADDONE's proven
# volatile-register clobber mask. A caller in another unit consults that loaded
# summary and narrows its caller-save spills exactly as in the intra-unit case;
# when the callee unit is compiled WITHOUT -OoIPARA the summary is absent and
# the caller falls back to the full ABI mask. Fixtures live in optsummary/.
here_fix="$here/optsummary"
xu="$(mktemp -d)"; trap 'rm -rf "$tmp" "$xu"' EXIT
cp "$here_fix/iparalib.pas" "$here_fix/caller_ipara.pp" "$xu/"

xu_pushes() { sed -n '/_HOT\$/,/\.size.*_HOT\$/p' "$1" | grep -Eci "$csregs" || true; }

# callee unit WITH -OoIPARA -> caller narrows spills
( cd "$xu" && "$CC" -Fu"$RTL" -O2 -OoIPARA iparalib.pas >/dev/null 2>&1 )
( cd "$xu" && "$CC" -Fu"$RTL" -Fu. -O2 -OoIPARA -al -s caller_ipara.pp >/dev/null 2>&1 )
xu_on=$(xu_pushes "$xu/caller_ipara.s")
# callee unit WITHOUT -OoIPARA -> summary absent, caller keeps full mask
( cd "$xu" && "$CC" -Fu"$RTL" -O2 iparalib.pas >/dev/null 2>&1 )
( cd "$xu" && "$CC" -Fu"$RTL" -Fu. -O2 -OoIPARA -al -s caller_ipara.pp >/dev/null 2>&1 )
xu_off=$(xu_pushes "$xu/caller_ipara.s")

echo "CROSS-UNIT callee -OoIPARA : callee-saved pushes in hot = $xu_on"
echo "CROSS-UNIT callee plain    : callee-saved pushes in hot = $xu_off"
[ "$xu_off" -ge 1 ]      || { echo "FAIL: expected caller-save spills with no cross-unit summary"; rc=1; }
[ "$xu_on" -lt "$xu_off" ] || { echo "FAIL: cross-unit -OoIPARA did not narrow caller-save pressure"; rc=1; }

# runtime correctness in both configurations
( cd "$xu" && "$CC" -Fu"$RTL" -O2 -OoIPARA iparalib.pas >/dev/null 2>&1 && \
              "$CC" -Fu"$RTL" -Fu. -O2 -OoIPARA caller_ipara.pp -ox_on >/dev/null 2>&1 )
( cd "$xu" && "$CC" -Fu"$RTL" -O2 iparalib.pas >/dev/null 2>&1 && \
              "$CC" -Fu"$RTL" -Fu. -O2 caller_ipara.pp -ox_off >/dev/null 2>&1 )
xr_on="$( ulimit -v 3000000; timeout 60 "$xu/x_on" )";  xe_on=$?
xr_off="$( ulimit -v 3000000; timeout 60 "$xu/x_off" )"; xe_off=$?
[ "$xe_on" -eq 0 ] && [ "$xe_off" -eq 0 ] && [ "$xr_on" = "$xr_off" ] || { echo "FAIL: cross-unit IPARA changed observable behaviour"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: cross-unit -OoIPARA narrows spills via the loaded ppu summary and is bit-exact"
exit $rc
