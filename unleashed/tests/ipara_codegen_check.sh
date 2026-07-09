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
exit $rc
