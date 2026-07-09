#!/usr/bin/env bash
# -OoICF symbol-alias mode + cross-unit folding checks.
#
# The file-at-a-time suite runner cannot express multi-unit fixtures nor inspect
# the emitted assembly, so the alias/cross-unit shapes are asserted here:
#
#  1. Alias mode: an address-never-taken duplicate (aliaslib.Foo/Bar) folds to a
#     ZERO-BYTE symbol alias -- the duplicate's symbol becomes a second label at
#     the survivor's address and NO jmp thunk is emitted for it; an address-taken
#     duplicate (Ping/Pong) instead falls back to a jmp thunk and keeps
#     @Ping<>@Pong (PtrsDistinct returns true at run time).
#  2. Cross-unit: xulibB.CalcB is byte-identical to xulibA.CalcA (a used unit),
#     so it folds into a jmp thunk to the external CalcA symbol via the
#     optsum_icf ppu summary; xulibB.CalcBdiff differs and must not fold.
#  3. Bit-exact behaviour with ICF on vs off, and under aggressive smartlinking.
#
# Usage: unleashed/tests/icf_check.sh [path-to-ppcx64]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"
FIX="$here/icf"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp "$FIX"/*.pas "$FIX"/*.pp "$tmp/"; cd "$tmp"
run(){ ( ulimit -v 3000000; timeout 60 "./$1" ); }
rc=0

# symbol (label) name for routine NAME in file $1, e.g. FOO -> ALIASLIB_$$_FOO$...
symname(){ grep -oE "[A-Za-z0-9_]+_\\\$\\\$_$1\\\$[A-Z\$]*" "$2" | head -1; }
# is routine $1's label emitted at routine $2's address (an alias), i.e. before
# any real instruction mnemonic following $2's label?
is_alias_after(){ awk -v a="$2:" -v b="$1:" '
  $0==a{seen=1;next}
  seen==1{ if($0==b){print "YES";exit}
           if($0 ~ /^\t[a-z]/){exit} }' "$3"; }

echo "== (1) alias mode =="
"$CC" -Fu"$RTL" -O2 -OoICF -a -s aliaslib.pas >/dev/null 2>&1
foo=$(symname FOO aliaslib.s); bar=$(symname BAR aliaslib.s)
ping=$(symname PING aliaslib.s); pong=$(symname PONG aliaslib.s)
if [ "$(is_alias_after "$bar" "$foo" aliaslib.s)" = YES ]; then
  echo "Foo/Bar: zero-byte alias (two labels at one address)"
else echo "FAIL: Bar not aliased onto Foo"; rc=1; fi
# symbol names contain '$', so match jmp targets by exact awk field compare
jmp_to(){ awk -v n="$1" '$1=="jmp" && $2==n{f=1} END{exit !f}' "$2"; }
if jmp_to "$foo" aliaslib.s; then echo "FAIL: unexpected jmp thunk to Foo"; rc=1; else echo "Foo/Bar: no jmp thunk emitted"; fi
if awk -v p="$ping" -v q="$pong" '$1=="jmp" && ($2==p||$2==q){f=1} END{exit !f}' aliaslib.s; then echo "Ping/Pong: jmp thunk fallback (address taken)"; else echo "FAIL: Ping/Pong did not thunk-fold"; rc=1; fi
if [ "$(is_alias_after "$pong" "$ping" aliaslib.s)" = YES ]; then echo "FAIL: Pong aliased despite address taken"; rc=1; else echo "Ping/Pong: not aliased (address preserved)"; fi

echo "== (2) cross-unit folding =="
"$CC" -Fu"$RTL" -O2 -OoICF xulibA.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O2 -OoICF -a -s xulibB.pas >/dev/null 2>&1
calcA=$(symname CALCA xulibB.s)
if jmp_to "$calcA" xulibB.s; then echo "CalcB: folded to external jmp $calcA"; else echo "FAIL: CalcB did not fold cross-unit"; rc=1; fi
# CalcBdiff must keep its own body: no jmp to CalcA within its bracket
if awk -v n="$calcA" '/_\$\$_CALCBDIFF\$/{f=1} f&&/\.size.*_CALCBDIFF\$/{f=0}
     f && $1=="jmp" && $2==n{bad=1} END{exit !bad}' xulibB.s; then
  echo "FAIL: CalcBdiff wrongly folded"; rc=1
else echo "CalcBdiff: not folded (body differs)"; fi

echo "== (3) bit-exact + smartlink =="
declare -a results
i=0
build_run(){ # $1=opts $2=tag
  "$CC" -Fu"$RTL" $1 xulibA.pas >/dev/null 2>&1
  "$CC" -Fu"$RTL" -Fu. $1 xulibB.pas >/dev/null 2>&1
  "$CC" -Fu"$RTL" -Fu. $1 xumain.pp -o"xm_$2" >/dev/null 2>&1
  "$CC" -Fu"$RTL" $1 aliaslib.pas >/dev/null 2>&1
  "$CC" -Fu"$RTL" -Fu. $1 aliasmain.pp -o"am_$2" >/dev/null 2>&1
}
for cfg in "-O2#off" "-O2 -OoICF#on" "-O2 -OoICF -XX -CX -Xs#smartlink"; do
  opt="${cfg%%#*}"; tag="${cfg##*#}"
  build_run "$opt" "$tag"
  xo="$(run xm_$tag)"; xe=$?
  ao="$(run am_$tag)"; ae=$?
  echo "[$tag] xumain='$xo'(exit $xe) aliasmain='$ao'(exit $ae)"
  [ "$xe" -eq 0 ] && [ "$ae" -eq 0 ] || { echo "FAIL: nonzero exit in cfg $tag"; rc=1; }
  results[$i]="$xo##$ao"; i=$((i+1))
done
for j in 1 2; do
  [ "${results[$j]}" = "${results[0]}" ] || { echo "FAIL: output not bit-exact ($j vs 0)"; rc=1; }
done

[ "$rc" -eq 0 ] && echo "PASS: -OoICF alias mode + cross-unit folding correct and bit-exact"
exit $rc
