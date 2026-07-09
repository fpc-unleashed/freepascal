#!/usr/bin/env bash
# Codegen assertion for the -OoPURE dead-store-elimination consumer.
#
# The extended (record-field / static-array-element) DSE in optdeadstore.pas
# used to treat EVERY call between two stores to the same slot as a hard barrier
# that keeps the earlier (dead) store alive. With -OoPURE the pass now relaxes
# that barrier for a call whose target is proven CONST or PURE, being precise
# about the pure-vs-const asymmetry:
#   * a CONST call reads/writes no memory  -> full non-barrier
#   * a PURE  call writes nothing but MAY READ globals -> a dead store to a
#     static var is KEPT (observable) while a dead store to a local is removed
#   * an IMPURE call stays a barrier
#
# This script proves the transform fires and is correctly gated by counting the
# eliminated constant store (movl $<const>) for four kernels. The runtime fixture
# testfiles/optpure/optpure_dse_01.pp proves the results stay correct. Assembly
# is inspected (-al -s) because mnemonics can't be matched by %CHECKBIN_*.
#
# Usage: unleashed/tests/pure_dse_check.sh [path-to-ppcx64]
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
type TArr = array[0..3] of longint;
var g: longint; sg: TArr;
function cpure(x: longint): longint; noinline;
begin cpure := x*x + 1; end;
function preads(x: longint): longint; noinline;
begin preads := g + x; end;
procedure impure(x: longint); noinline;
begin g := g + x; end;
function wconst(v: longint): longint; noinline;
var a: TArr; t: longint;
begin a[0]:=111; a[1]:=11; a[2]:=12; a[3]:=13; t:=cpure(v); a[0]:=222;
  wconst:=a[0]+a[1]+a[2]+a[3]+t; end;
function wimpure(v: longint): longint; noinline;
var a: TArr;
begin a[0]:=333; a[1]:=21; a[2]:=22; a[3]:=23; impure(v); a[0]:=444;
  wimpure:=a[0]+a[1]+a[2]+a[3]; end;
function wpurelocal(v: longint): longint; noinline;
var a: TArr; t: longint;
begin a[0]:=555; a[1]:=31; a[2]:=32; a[3]:=33; t:=preads(v); a[0]:=666;
  wpurelocal:=a[0]+a[1]+a[2]+a[3]+t; end;
function wpurestatic(v: longint): longint; noinline;
var t: longint;
begin sg[0]:=777; sg[1]:=41; sg[2]:=42; sg[3]:=43; t:=preads(v); sg[0]:=888;
  wpurestatic:=sg[0]+sg[1]+sg[2]+sg[3]+t; end;
begin writeln(wconst(2)+wimpure(3)+wpurelocal(4)+wpurestatic(5)); end.
EOF

# count occurrences of a `movl $<const>` store
count_store() { grep -cE "movl[[:space:]]+\\\$$1," "$2" || true; }

# ---- with -OoPURE: relaxation active ---------------------------------------
"$CC" -Fu"$RTL" -O3 -OoPURE -Oodeadstore -al -s "$tmp/k.pp" -FE"$tmp" >/dev/null 2>&1
c111=$(count_store 111 "$tmp/k.s")   # const call between  -> removed (0)
c333=$(count_store 333 "$tmp/k.s")   # impure call between -> kept    (1)
c555=$(count_store 555 "$tmp/k.s")   # pure call, local    -> removed (0)
c777=$(count_store 777 "$tmp/k.s")   # pure call, static   -> kept    (1)

# ---- baseline without -OoPURE: every call is a barrier, all kept -----------
"$CC" -Fu"$RTL" -O3 -Oodeadstore -al -s "$tmp/k.pp" -FE"$tmp" >/dev/null 2>&1
b111=$(count_store 111 "$tmp/k.s")   # kept (1)
b555=$(count_store 555 "$tmp/k.s")   # kept (1)

echo "with -OoPURE:  const-call dead store  111 count=$c111 (expect 0, removed)"
echo "with -OoPURE:  impure-call dead store 333 count=$c333 (expect 1, kept)"
echo "with -OoPURE:  pure-call local  store 555 count=$c555 (expect 0, removed)"
echo "with -OoPURE:  pure-call static store 777 count=$c777 (expect 1, kept)"
echo "baseline    :  111 count=$b111, 555 count=$b555 (expect 1,1 kept)"

rc=0
[ "$c111" = "0" ] || { echo "FAIL: dead store not removed across a const call"; rc=1; }
[ "$c333" = "1" ] || { echo "FAIL: dead store wrongly removed across an impure call"; rc=1; }
[ "$c555" = "0" ] || { echo "FAIL: dead store to a local not removed across a pure call"; rc=1; }
[ "$c777" = "1" ] || { echo "FAIL: dead store to a static var wrongly removed across a pure (global-reading) call"; rc=1; }
[ "$b111" = "1" ] || { echo "FAIL: baseline (no -OoPURE) wrongly removed store across a call"; rc=1; }
[ "$b555" = "1" ] || { echo "FAIL: baseline (no -OoPURE) wrongly removed store across a call"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: pure/const calls are non-barriers for DSE with correct pure-vs-const asymmetry"
exit "$rc"
