#!/usr/bin/env bash
# Codegen + semantics checks for -OoUNROLLDYN (dynamic-trip loop unrolling) and
# -OoPREFETCH (software prefetch).
#
# Part A (codegen) inspects the emitted assembly (-al -s): the unroller must
# replicate the body 4x with a scalar remainder, and -OoPREFETCH must emit a
# PREFETCHNTA of the streamed base -- and neither may fire with its switch off
# nor on a loop the gates reject (a body with a call). The bundled byte-based
# %CHECKBIN_* directive cannot match an instruction mnemonic (prefetchnta is not
# a string in the binary), so we grep the .s like slp_codegen_check.sh does.
#
# Part B (semantics) recompiles every runtime test under testfiles/optunrolldyn/
# with the switches ON and OFF, runs both, and asserts each exits 0 and prints
# byte-identical stdout -- proving unroll+prefetch change nothing observable.
#
# Usage: unleashed/tests/unrolldyn_check.sh [path-to-ppcx64]
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

rc=0
fail() { echo "FAIL: $*"; rc=1; }

# ---------------------------------------------------------------------------
# Part A: codegen
# ---------------------------------------------------------------------------
cat > "$tmp/k.pp" <<'EOF'
program k;
{$mode objfpc}{$H+}
type TA = array of single;
procedure kern(a,b: TA; n: integer; s: single);
var i: integer;
begin
  for i:=0 to n-1 do a[i]:=b[i]*s;
end;
procedure withcall(a,b: TA; n: integer);
var i: integer;
begin
  for i:=0 to n-1 do a[i]:=Sqrt(b[i]);   { a call in the body: gate must reject }
end;
var a,b: TA; i: integer;
begin
  SetLength(a,1000); SetLength(b,1000);
  for i:=0 to 999 do b[i]:=i*0.5;
  kern(a,b,1000,2.0);
  withcall(a,b,1000);
  writeln(a[0]:0:1);
end.
EOF

asm_for() {  # $1 = flags -> echoes "<prefetch> <bodymul>"
  local d="$tmp/$2"
  mkdir -p "$d"; cp "$tmp/k.pp" "$d/"
  ( cd "$d" && "$CC" -Fu"$RTL" $1 -al -s k.pp >/dev/null 2>&1 )
  local pf mul
  pf=$(grep -ci prefetchnta "$d/k.s" 2>/dev/null || true)
  mul=$(grep -ci mulss "$d/k.s" 2>/dev/null || true)
  echo "$pf $mul"
}

read on_pf   on_mul   < <(asm_for "-O3 -OoUNROLLDYN -OoPREFETCH" both)
read un_pf   un_mul   < <(asm_for "-O3 -OoUNROLLDYN"             unroll)
read pf_pf   pf_mul   < <(asm_for "-O3 -OoPREFETCH"              prefetch)
read off_pf  off_mul  < <(asm_for "-O3"                          off)

echo "UNROLLDYN+PREFETCH : prefetchnta=$on_pf  mulss=$on_mul"
echo "UNROLLDYN only     : prefetchnta=$un_pf  mulss=$un_mul"
echo "PREFETCH only      : prefetchnta=$pf_pf  mulss=$pf_mul"
echo "neither            : prefetchnta=$off_pf mulss=$off_mul"

# With both: prefetch emitted, and body replicated (4 unrolled + 1 remainder).
[ "$on_pf"  -ge 1 ] || fail "expected prefetchnta with -OoPREFETCH"
[ "$on_mul" -ge 4 ] || fail "expected the body replicated >=4x under -OoUNROLLDYN (got mulss=$on_mul)"
# Unroll only: no prefetch, still replicated.
[ "$un_pf"  -eq 0 ] || fail "unexpected prefetchnta without -OoPREFETCH"
[ "$un_mul" -ge 4 ] || fail "expected the body replicated under -OoUNROLLDYN only"
# Prefetch only: prefetch emitted, body NOT replicated (one mulss in the loop).
[ "$pf_pf"  -ge 1 ] || fail "expected prefetchnta under -OoPREFETCH only"
[ "$pf_mul" -le 2 ] || fail "body should not be unrolled under -OoPREFETCH only (mulss=$pf_mul)"
# Neither: plain scalar loop.
[ "$off_pf" -eq 0 ] || fail "unexpected prefetchnta with neither switch"
[ "$off_mul" -le 2 ] || fail "body unexpectedly unrolled with neither switch"

# ---------------------------------------------------------------------------
# Part B: semantics (ON vs OFF must be byte-identical stdout, both exit 0)
# ---------------------------------------------------------------------------
for src in "$here"/testfiles/optunrolldyn/*.pp; do
  name="$(basename "$src" .pp)"
  d="$tmp/sem_$name"; mkdir -p "$d/on" "$d/off"
  cp "$src" "$d/on/"; cp "$src" "$d/off/"
  ( cd "$d/on"  && "$CC" -Fu"$RTL" -O3 -OoUNROLLDYN -OoPREFETCH -o"$d/on/e"  "$name.pp" >/dev/null 2>&1 )
  ( cd "$d/off" && "$CC" -Fu"$RTL" -O3                          -o"$d/off/e" "$name.pp" >/dev/null 2>&1 )
  if [ ! -x "$d/on/e" ]  ; then fail "$name did not compile with switches ON";  continue; fi
  if [ ! -x "$d/off/e" ] ; then fail "$name did not compile with switches OFF"; continue; fi
  out_on="$("$d/on/e";  echo "exit=$?")"
  out_off="$("$d/off/e"; echo "exit=$?")"
  if [ "$out_on" != "$out_off" ]; then
    fail "$name: ON/OFF output differ"
    echo "  ON : $out_on"
    echo "  OFF: $out_off"
  elif [[ "$out_on" != *"exit=0"* ]]; then
    fail "$name: nonzero exit ($out_on)"
  else
    echo "sem $name: identical, $out_on"
  fi
done

[ "$rc" -eq 0 ] && echo "PASS: unroll replicates + prefetch emits; gates hold; semantics unchanged"
exit "$rc"
