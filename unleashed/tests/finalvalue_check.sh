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
{$mode objfpc}{$H+}
interface
function accum(n: longint): longint;
function emptyloop(n: longint): longint;
function withbreak(n: longint): longint;
implementation
function accum(n: longint): longint;
var i,s: longint;
begin s:=10; for i:=1 to n do inc(s,3); accum:=s; end;
function emptyloop(n: longint): longint;
var i: longint;
begin for i:=1 to n do ; emptyloop:=42; end;
function withbreak(n: longint): longint;
var i,s: longint;
begin s:=0; for i:=1 to n do begin inc(s,3); if i=3 then break; end; withbreak:=s; end;
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
  echo "$(branches_in "$f" 'ACCUM') $(branches_in "$f" 'EMPTYLOOP') $(branches_in "$f" 'WITHBREAK')"
}

read on_acc  on_empty  on_brk  < <(asm_for "-O2 -OoFINALVALUE" on)
read off_acc off_empty off_brk < <(asm_for "-O2"              off)

echo "ON  : accum_backedges=$on_acc  empty_backedges=$on_empty  break_backedges=$on_brk"
echo "OFF : accum_backedges=$off_acc empty_backedges=$off_empty break_backedges=$off_brk"

# ON: the accumulator loop and the empty loop are deleted -> no loop back-edge.
[ "$on_acc"   -eq 0  ] || fail "accumulator loop not deleted under -OoFINALVALUE (back-edges=$on_acc)"
[ "$on_empty" -eq 0  ] || fail "empty loop not deleted under -OoFINALVALUE (back-edges=$on_empty)"
# OFF: both loops are present -> a back-edge each.
[ "$off_acc"   -ge 1 ] || fail "accumulator loop unexpectedly absent with switch OFF"
[ "$off_empty" -ge 1 ] || fail "empty loop unexpectedly absent with switch OFF"
# The break loop is rejected by the gates -> kept identically on and off.
[ "$on_brk"    -ge 1 ] || fail "loop with break lost its back-edge (should be kept)"
[ "$on_brk"   -eq "$off_brk" ] || fail "loop with break altered under -OoFINALVALUE (on=$on_brk off=$off_brk)"

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
