#!/usr/bin/env bash
# Cross-unit -OoPURE via the shared per-procdef PPU optimizer-summary mechanism.
#
# The file-at-a-time suite runner has no notion of an auxiliary unit, so the
# cross-unit fixtures (optsummary/purelib.pas + optsummary/caller_pure.pp) are
# driven from here. This proves three things:
#   1. When purelib is compiled WITH -OoPURE, its const verdict is serialized to
#      purelib.ppu; a caller in another unit then commons three identical CALC
#      calls to ONE under -OoGVNPRE (cross-unit CSE fires).
#   2. When purelib is compiled WITHOUT -OoPURE (stale/absent summary), the
#      caller conservatively keeps all three calls -- and is still correct.
#   3. Behaviour is bit-exact: the program prints the same result and exits 0 in
#      every configuration (summary present, absent, switches off).
#
# Usage: unleashed/tests/optsummary_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"
FIX="$here/optsummary"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cp "$FIX/purelib.pas" "$FIX/caller_pure.pp" "$tmp/"
cd "$tmp"

callcount() { # count direct calls to CALC inside redund()
  sed -n '/_REDUND\$/,/\.size.*_REDUND\$/p' "$1" | grep -Eci 'call.*CALC' || true
}

rc=0

# (1) library WITH -OoPURE -> cross-unit CSE
"$CC" -Fu"$RTL" -O2 -OoPURE purelib.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O4 -OoPURE -OoGVNPRE -al -s caller_pure.pp >/dev/null 2>&1
on=$(callcount caller_pure.s)
echo "lib -OoPURE  : CALC calls in redund = $on"

# (2) library WITHOUT -OoPURE -> conservative fallback (absent summary)
"$CC" -Fu"$RTL" -O2 purelib.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O4 -OoPURE -OoGVNPRE -al -s caller_pure.pp >/dev/null 2>&1
off=$(callcount caller_pure.s)
echo "lib plain    : CALC calls in redund = $off"

[ "$on" -eq 1 ]     || { echo "FAIL: expected 1 call cross-unit when the pure summary is present"; rc=1; }
[ "$off" -ge 3 ]    || { echo "FAIL: expected >=3 calls when the pure summary is absent"; rc=1; }
[ "$on" -lt "$off" ]|| { echo "FAIL: cross-unit -OoPURE did not reduce the call count"; rc=1; }

# (3) runtime correctness / bit-exact behaviour in every configuration
run() { ( ulimit -v 3000000; timeout 60 "./$1" ); }
outs=""
# a) lib pure + caller pure/gvnpre
"$CC" -Fu"$RTL" -O2 -OoPURE purelib.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O4 -OoPURE -OoGVNPRE caller_pure.pp -oc_a >/dev/null 2>&1
# b) lib plain + caller pure/gvnpre (stale/absent)
"$CC" -Fu"$RTL" -O2 purelib.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O4 -OoPURE -OoGVNPRE caller_pure.pp -oc_b >/dev/null 2>&1
# c) everything off
"$CC" -Fu"$RTL" -O2 purelib.pas >/dev/null 2>&1
"$CC" -Fu"$RTL" -Fu. -O2 caller_pure.pp -oc_c >/dev/null 2>&1
for x in c_a c_b c_c; do
  o="$(run $x)"; e=$?
  echo "run $x: '$o' (exit $e)"
  [ "$e" -eq 0 ] || { echo "FAIL: $x exited $e"; rc=1; }
  outs+="$o|"
done
[ "$outs" = "ALL OK|ALL OK|ALL OK|" ] || { echo "FAIL: output differs across configurations"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: cross-unit -OoPURE summary CSEs a used-unit const call and is bit-exact"
exit $rc
