#!/usr/bin/env bash
# Codegen assertion for -OoSLP (superword-level parallelism vectorization).
#
# The runtime tests under testfiles/optslp/ prove SLP is bit-exact; this script
# proves it actually EMITS packed SSE ops. The bundled byte-based %CHECKBIN_*
# directive cannot match instruction mnemonics, so we inspect the emitted
# assembly (-al -s) instead: a 4-wide adjacent single-precision group must
# lower to one packed addps + movups loads/store and NO scalar addss, and the
# same source with the switch off must stay scalar (addss, no addps/movups).
#
# Usage: unleashed/tests/slp_codegen_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/k.pp" <<'EOF'
program k;
{$mode objfpc}{$H+}
type TA = array of single;
procedure add4(a,b,c: TA);
begin
  a[0]:=b[0]+c[0]; a[1]:=b[1]+c[1]; a[2]:=b[2]+c[2]; a[3]:=b[3]+c[3];
end;
var a,b,c: TA; i: integer;
begin
  SetLength(a,4); SetLength(b,4); SetLength(c,4);
  for i:=0 to 3 do begin b[i]:=i+1; c[i]:=i+1; end;
  add4(a,b,c);
  writeln(a[0]:0:1);
end.
EOF

mkdir -p "$tmp/on" "$tmp/off"
cp "$tmp/k.pp" "$tmp/on/"; cp "$tmp/k.pp" "$tmp/off/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O4 -OoSLP -Cfsse64 -al -s k.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O4         -Cfsse64 -al -s k.pp >/dev/null 2>&1 )

on_addps=$(grep -ci addps  "$tmp/on/k.s"  || true)
on_movups=$(grep -ci movups "$tmp/on/k.s" || true)
on_addss=$(grep -ci addss   "$tmp/on/k.s" || true)
off_addps=$(grep -ci addps  "$tmp/off/k.s" || true)
off_addss=$(grep -ci addss  "$tmp/off/k.s" || true)

echo "ON  -OoSLP : addps=$on_addps movups=$on_movups addss=$on_addss"
echo "OFF        : addps=$off_addps addss=$off_addss"

rc=0
[ "$on_addps" -ge 1 ]  || { echo "FAIL: expected a packed addps under -OoSLP"; rc=1; }
[ "$on_movups" -ge 3 ] || { echo "FAIL: expected packed movups loads/store under -OoSLP"; rc=1; }
[ "$on_addss" -eq 0 ]  || { echo "FAIL: scalar addss still present under -OoSLP"; rc=1; }
[ "$off_addps" -eq 0 ] || { echo "FAIL: unexpected packed addps with SLP off"; rc=1; }
[ "$off_addss" -ge 4 ] || { echo "FAIL: expected 4 scalar addss with SLP off"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: SLP packs the 4-wide group; control stays scalar"
exit "$rc"
