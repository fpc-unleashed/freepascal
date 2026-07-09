#!/usr/bin/env bash
# Codegen + semantics checks for -OoFINALVALUE (final value replacement + dead
# loop elimination).
#
# Part A (codegen) inspects the emitted assembly (-al -s): with the switch ON an
# eligible accumulator loop and an empty counted loop must lose their back-edge
# branch entirely (the loop is deleted, replaced by the closed form), while a
# loop the gates reject (a break in the body) must keep its loop. With the
# switch OFF every loop keeps its branch. The bundled byte-based %CHECKBIN_*
# directive cannot assert the absence of a specific control-flow instruction, so
# we grep the .s like slp/unrolldyn_check.sh do.
#
# Part B (semantics) recompiles every runtime test under testfiles/optfinalvalue/
# with the switch ON and OFF, runs both, and asserts each exits 0 and prints
# byte-identical stdout -- proving the transform changes nothing observable.
#
# Usage: unleashed/tests/finalvalue_check.sh [path-to-ppcx64]
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
# Part A: codegen. Three routines: an accumulator loop and an empty loop (both
# eligible -> deleted), and a loop with a break (rejected -> kept).
# ---------------------------------------------------------------------------
cat > "$tmp/k.pp" <<'EOF'
unit k;
{$mode objfpc}{$H+}{$POINTERMATH ON}
interface
type PLongint = ^Longint;
function accum(n: longint): longint;
function emptyloop(n: longint): longint;
function withbreak(n: longint): longint;
function ptrinc(base: PLongint; n: longint): PtrInt;    { pointer stride -> deleted }
function multiacc(n: longint): longint;                 { two accumulators -> deleted }
function dupacc(n: longint): longint;                   { same acc twice -> kept }
function ptrassign(base: PLongint; n: longint): PtrInt; { p:=p+stride form -> kept }
function cnt64(a,b: int64): int64;                      { 64-bit counter -> deleted }
function natacc(n: longint): int64;                     { native int64 acc -> deleted; kept OFF; deleted under -Cr }
function gacc(n: longint): int64;                       { global int64 acc -> deleted; deleted under -Cr }
implementation
var gv: int64;
function accum(n: longint): longint;
var i,s: longint;
begin s:=10; for i:=1 to n do inc(s,3); accum:=s; end;
function emptyloop(n: longint): longint;
var i: longint;
begin for i:=1 to n do ; emptyloop:=42; end;
function withbreak(n: longint): longint;
var i,s: longint;
begin s:=0; for i:=1 to n do begin inc(s,3); if i=3 then break; end; withbreak:=s; end;
function ptrinc(base: PLongint; n: longint): PtrInt;
var i: longint; p: PLongint;
begin p:=base; for i:=1 to n do inc(p,2); ptrinc:=PtrInt(p)-PtrInt(base); end;
function multiacc(n: longint): longint;
var i,s,t: longint;
begin s:=0; t:=0; for i:=1 to n do begin inc(s,3); dec(t,2); end; multiacc:=s+t; end;
function dupacc(n: longint): longint;
var i,s: longint;
begin s:=0; for i:=1 to n do begin inc(s,3); inc(s,5); end; dupacc:=s; end;
function ptrassign(base: PLongint; n: longint): PtrInt;
var i: longint; p: PLongint;
begin p:=base; for i:=1 to n do p:=p+2; ptrassign:=PtrInt(p)-PtrInt(base); end;
function cnt64(a,b: int64): int64;
var i,s: int64;
begin s:=0; for i:=a to b do inc(s,3); cnt64:=s; end;
function natacc(n: longint): int64;
var i: longint; s: int64;
begin s:=0; for i:=1 to n do inc(s,3); natacc:=s; end;
function gacc(n: longint): int64;
var i: longint;
begin gv:=0; for i:=1 to n do inc(gv,3); gacc:=gv; end;
end.
EOF

# count loop BACK-EDGES inside one routine: a conditional jump whose target
# label was already defined earlier in the same routine. A counted loop has
# exactly such a back-edge; the closed-form replacement (a forward if-guard) and
# an outright-deleted loop have none. FPC lays functions out as:
#     .globl SYM
#         .type SYM,@function
#     SYM:            <- label line ending in ':'
#         ... body ...
#     .globl NEXTSYM  <- next function starts here
# so a routine spans from its label line to the next .globl (or EOF).
branches_in() {  # $1=asmfile  $2=SYMBOL-substring  -> prints back-edge count
  awk -v sym="$2" '
    /^[ \t]*\.globl/ { inr=0 }
    $0 ~ ("^[A-Za-z_].*" sym ".*:[ \t]*$") { inr=1; delete seen; next }
    inr && /^\.L[A-Za-z0-9_]+:/ {
      lbl=$0; sub(/:.*/,"",lbl); seen[lbl]=1; next
    }
    inr && $0 ~ /^[ \t]*j[a-z]+[ \t]+\.L/ {
      tgt=$2
      if (tgt in seen) c++    # jump target already defined above -> back-edge
    }
    END { print c+0 }' "$1"
}

asm_for() {  # $1=flags $2=tag ; sets globals via echo "acc empty brk"
  local d="$tmp/$2"
  mkdir -p "$d"; cp "$tmp/k.pp" "$d/"
  ( cd "$d" && "$CC" -Fu"$RTL" $1 -al -s k.pp >/dev/null 2>&1 )
  local f="$d/k.s"
  # accum empty break  ptrinc multiacc  dupacc ptrassign cnt64 natacc gacc
  echo "$(branches_in "$f" 'ACCUM') $(branches_in "$f" 'EMPTYLOOP') $(branches_in "$f" 'WITHBREAK') $(branches_in "$f" 'PTRINC') $(branches_in "$f" 'MULTIACC') $(branches_in "$f" 'DUPACC') $(branches_in "$f" 'PTRASSIGN') $(branches_in "$f" 'CNT64') $(branches_in "$f" 'NATACC') $(branches_in "$f" 'GACC')"
}

read on_acc  on_empty  on_brk  on_pinc  on_multi  on_dup  on_passign  on_c64  on_nat  on_g  < <(asm_for "-O2 -OoFINALVALUE" on)
read off_acc off_empty off_brk off_pinc off_multi off_dup off_passign off_c64 off_nat off_g < <(asm_for "-O2"              off)

echo "ON  : accum=$on_acc empty=$on_empty break=$on_brk ptrinc=$on_pinc multiacc=$on_multi dupacc=$on_dup ptrassign=$on_passign"
echo "OFF : accum=$off_acc empty=$off_empty break=$off_brk ptrinc=$off_pinc multiacc=$off_multi dupacc=$off_dup ptrassign=$off_passign"

# ON: eligible loops deleted -> no loop back-edge.
[ "$on_acc"   -eq 0  ] || fail "accumulator loop not deleted under -OoFINALVALUE (back-edges=$on_acc)"
[ "$on_empty" -eq 0  ] || fail "empty loop not deleted under -OoFINALVALUE (back-edges=$on_empty)"
[ "$on_pinc"  -eq 0  ] || fail "pointer-stride loop not deleted under -OoFINALVALUE (back-edges=$on_pinc)"
[ "$on_multi" -eq 0  ] || fail "multi-accumulator loop not deleted under -OoFINALVALUE (back-edges=$on_multi)"
# OFF: every loop is present -> a back-edge each.
[ "$off_acc"   -ge 1 ] || fail "accumulator loop unexpectedly absent with switch OFF"
[ "$off_empty" -ge 1 ] || fail "empty loop unexpectedly absent with switch OFF"
[ "$off_pinc"  -ge 1 ] || fail "pointer-stride loop unexpectedly absent with switch OFF"
[ "$off_multi" -ge 1 ] || fail "multi-accumulator loop unexpectedly absent with switch OFF"
# Rejected loops -> kept identically on and off.
[ "$on_brk"     -ge 1 ] || fail "loop with break lost its back-edge (should be kept)"
[ "$on_brk"     -eq "$off_brk" ]     || fail "loop with break altered under -OoFINALVALUE (on=$on_brk off=$off_brk)"
[ "$on_dup"     -ge 1 ] || fail "duplicate-accumulator loop lost its back-edge (should be kept)"
[ "$on_dup"     -eq "$off_dup" ]     || fail "duplicate-accumulator loop altered under -OoFINALVALUE (on=$on_dup off=$off_dup)"
[ "$on_passign" -ge 1 ] || fail "pointer-assign loop lost its back-edge (should be kept)"
[ "$on_passign" -eq "$off_passign" ] || fail "pointer-assign loop altered under -OoFINALVALUE (on=$on_passign off=$off_passign)"
# 64-bit counter, native int64 accumulator, and global accumulator -> all deleted ON, present OFF.
echo "ON  : cnt64=$on_c64 natacc=$on_nat gacc=$on_g   OFF: cnt64=$off_c64 natacc=$off_nat gacc=$off_g"
[ "$on_c64"  -eq 0 ] || fail "64-bit counter loop not deleted under -OoFINALVALUE (back-edges=$on_c64)"
[ "$on_nat"  -eq 0 ] || fail "native int64 accumulator loop not deleted under -OoFINALVALUE (back-edges=$on_nat)"
[ "$on_g"    -eq 0 ] || fail "global accumulator loop not deleted under -OoFINALVALUE (back-edges=$on_g)"
[ "$off_c64" -ge 1 ] || fail "64-bit counter loop unexpectedly absent with switch OFF"
[ "$off_nat" -ge 1 ] || fail "native int64 accumulator loop unexpectedly absent with switch OFF"
[ "$off_g"   -ge 1 ] || fail "global accumulator loop unexpectedly absent with switch OFF"

# ---------------------------------------------------------------------------
# Part A2: overflow/range-check regimes.
#   -Cr (range, no -Co): enabled only for native full-range integer accumulators
#     (natacc, gacc, cnt64 -> deleted) while a sub-native accumulator (accum,
#     longint) is range-checked on its narrowing store -> KEPT.
#   -Co (overflow): fully disabled -> every loop KEPT (matches OFF).
# ---------------------------------------------------------------------------
read cr_acc cr_empty cr_brk cr_pinc cr_multi cr_dup cr_passign cr_c64 cr_nat cr_g < <(asm_for "-O2 -Cr -OoFINALVALUE" cr)
read co_acc co_empty co_brk co_pinc co_multi co_dup co_passign co_c64 co_nat co_g < <(asm_for "-O2 -Co -OoFINALVALUE" co)
echo "-Cr : accum=$cr_acc natacc=$cr_nat gacc=$cr_g cnt64=$cr_c64 empty=$cr_empty"
echo "-Co : accum=$co_acc natacc=$co_nat gacc=$co_g cnt64=$co_c64 empty=$co_empty"
# -Cr: native accumulators deleted, sub-native kept.
[ "$cr_nat" -eq 0 ] || fail "native int64 accumulator not deleted under -Cr (back-edges=$cr_nat)"
[ "$cr_g"   -eq 0 ] || fail "global int64 accumulator not deleted under -Cr (back-edges=$cr_g)"
[ "$cr_c64" -eq 0 ] || fail "64-bit-counter native accumulator not deleted under -Cr (back-edges=$cr_c64)"
[ "$cr_acc" -ge 1 ] || fail "sub-native accumulator wrongly deleted under -Cr (would skip its range check)"
# -Co: pass fully disabled -> nothing deleted (every routine keeps its loop).
[ "$co_acc"   -ge 1 ] || fail "accumulator loop deleted under -Co (must stay to trap on overflow)"
[ "$co_nat"   -ge 1 ] || fail "native accumulator loop deleted under -Co (must stay to trap on overflow)"
[ "$co_g"     -ge 1 ] || fail "global accumulator loop deleted under -Co"
[ "$co_c64"   -ge 1 ] || fail "64-bit-counter loop deleted under -Co"
[ "$co_empty" -ge 1 ] || fail "empty loop deleted under -Co"

# ---------------------------------------------------------------------------
# Part B: semantics (ON vs OFF byte-identical stdout, both exit 0)
# ---------------------------------------------------------------------------
for src in "$here"/testfiles/optfinalvalue/*.pp; do
  name="$(basename "$src" .pp)"
  d="$tmp/sem_$name"; mkdir -p "$d/on" "$d/off"
  cp "$src" "$d/on/"; cp "$src" "$d/off/"
  ( cd "$d/on"  && "$CC" -Fu"$RTL" -O2 -OoFINALVALUE -o"$d/on/e"  "$name.pp" >/dev/null 2>&1 )
  ( cd "$d/off" && "$CC" -Fu"$RTL" -O2               -o"$d/off/e" "$name.pp" >/dev/null 2>&1 )
  if [ ! -x "$d/on/e" ]  ; then fail "$name did not compile with switch ON";  continue; fi
  if [ ! -x "$d/off/e" ] ; then fail "$name did not compile with switch OFF"; continue; fi
  out_on="$( ("$d/on/e";  echo "exit=$?") )"
  out_off="$( ("$d/off/e"; echo "exit=$?") )"
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

[ "$rc" -eq 0 ] && echo "PASS: eligible loops deleted; rejected loops kept; semantics unchanged"
exit "$rc"
