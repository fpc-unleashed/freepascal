#!/usr/bin/env bash
# Codegen assertion for -OoSTACKALLOC (escape-analysis stack allocation of a
# non-escaping local dynamic array).
#
# The runtime tests under testfiles/stackalloc/ prove behaviour is unchanged;
# this script proves the transform actually ELIDES the heap allocation. The
# byte-based %CHECKBIN_* directive cannot see call targets in a stripped
# binary, so we inspect the emitted assembly (-al -s): a non-escaping
# SetLength(a,N) with N a small constant must emit NO fpc_dynarray_setlength /
# fpc_getmem call for that routine (the buffer becomes a frame local, zeroed
# with a FILLCHAR), while an escaping one (returned) must still allocate.
#
# Usage: unleashed/tests/stackalloc_codegen_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# NONESCAPE: a is a plain local, only indexed / Length'd -> stack-allocated.
cat > "$tmp/ne.pp" <<'EOF'
program ne;
{$mode objfpc}
function noesc: longint;
var a: array of longint; i,s: longint;
begin
  SetLength(a,8);
  for i:=0 to High(a) do a[i]:=i*i;
  s:=0; for i:=0 to Length(a)-1 do inc(s,a[i]);
  noesc:=s;
end;
begin writeln(noesc); end.
EOF

# ESCAPE: the array is returned -> must NOT be transformed (still allocates).
cat > "$tmp/es.pp" <<'EOF'
program es;
{$mode objfpc}
type TA = array of longint;
function esc: TA;
begin SetLength(result,8); result[0]:=1; end;
begin writeln(esc[0]); end.
EOF

mkdir -p "$tmp/on" "$tmp/off" "$tmp/es"
cp "$tmp/ne.pp" "$tmp/on/"; cp "$tmp/ne.pp" "$tmp/off/"; cp "$tmp/es.pp" "$tmp/es/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O2 -OoSTACKALLOC -al -s ne.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O2               -al -s ne.pp >/dev/null 2>&1 )
( cd "$tmp/es"  && "$CC" -Fu"$RTL" -O2 -OoSTACKALLOC -al -s es.pp >/dev/null 2>&1 )

# Restrict the grep to the NOESC / ESC routine body only.
body() { awk "/_\\\$\\\$_$2\\\$/{f=1} f{print} /\.size.*_$2\\\$/{f=0}" "$1"; }

on_setlen=$(body  "$tmp/on/ne.s"  NOESC | grep -ci "dynarray_setlength\|fpc_getmem" || true)
on_fill=$(body    "$tmp/on/ne.s"  NOESC | grep -ci "FILLCHAR" || true)
off_setlen=$(body "$tmp/off/ne.s" NOESC | grep -ci "dynarray_setlength" || true)
es_setlen=$(body  "$tmp/es/es.s"  ESC   | grep -ci "dynarray_setlength" || true)

echo "ON  noesc  : dynarray_setlength/getmem=$on_setlen fillchar=$on_fill"
echo "OFF noesc  : dynarray_setlength=$off_setlen"
echo "ON  esc    : dynarray_setlength=$es_setlen"

rc=0
[ "$on_setlen" -eq 0 ] || { echo "FAIL: non-escaping array still allocates under -OoSTACKALLOC"; rc=1; }
[ "$on_fill"  -ge 1 ]  || { echo "FAIL: expected a FILLCHAR zeroing the stack buffer"; rc=1; }
[ "$off_setlen" -ge 1 ] || { echo "FAIL: expected heap SetLength with the switch off"; rc=1; }
[ "$es_setlen"  -ge 1 ] || { echo "FAIL: escaping (returned) array must still allocate"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: non-escaping dynarray is stack-allocated; escaping one still allocates"
exit "$rc"
