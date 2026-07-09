#!/usr/bin/env bash
# Codegen assertion for the -OoVECTORIZE double-precision loop autovectorizer.
#
# The runtime tests under testfiles/optvect/vect_double_* prove double
# vectorization is bit-exact; this script proves it actually EMITS 128-bit
# packed double ops (movupd/addpd, VL=2) and that the transform is correctly
# gated: with the switch OFF the same loop stays scalar (addsd, no addpd), and
# a MIXED single/double loop must NEVER vectorize (no addpd) even with the
# switch on. The bundled byte-based %CHECKBIN_* directive cannot match
# instruction mnemonics, so we inspect the emitted assembly (-al -s) instead.
#
# Usage: unleashed/tests/vectorize_double_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# double element-wise add over dynamic arrays: the canonical vectorizable shape
cat > "$tmp/k.pp" <<'EOF'
program k;
{$mode objfpc}{$H+}
type TD = array of double;
procedure add(a,b,c: TD; n: longint);
var i: longint;
begin
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
end;
var a,b,c: TD; i: longint;
begin
  SetLength(a,64); SetLength(b,64); SetLength(c,64);
  for i:=0 to 63 do begin b[i]:=i+1; c[i]:=i+1; end;
  add(a,b,c,64);
  writeln(a[0]:0:1);
end.
EOF

# mixed single/double: b is single, promoted to double -> must stay scalar
cat > "$tmp/m.pp" <<'EOF'
program m;
{$mode objfpc}{$H+}
type TD = array of double; TS = array of single;
procedure add(a,c: TD; b: TS; n: longint);
var i: longint;
begin
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
end;
var a,c: TD; b: TS; i: longint;
begin
  SetLength(a,64); SetLength(b,64); SetLength(c,64);
  for i:=0 to 63 do begin b[i]:=i+1; c[i]:=i+1; end;
  add(a,c,b,64);
  writeln(a[0]:0:1);
end.
EOF

mkdir -p "$tmp/on" "$tmp/off" "$tmp/mix"
cp "$tmp/k.pp" "$tmp/on/"; cp "$tmp/k.pp" "$tmp/off/"; cp "$tmp/m.pp" "$tmp/mix/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O4 -OoVECTORIZE -Cfsse64 -al -s k.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O4              -Cfsse64 -al -s k.pp >/dev/null 2>&1 )
( cd "$tmp/mix" && "$CC" -Fu"$RTL" -O4 -OoVECTORIZE -Cfsse64 -al -s m.pp >/dev/null 2>&1 )

on_addpd=$(grep -ci addpd  "$tmp/on/k.s"  || true)
on_movupd=$(grep -ci movupd "$tmp/on/k.s" || true)
off_addpd=$(grep -ci addpd  "$tmp/off/k.s" || true)
off_addsd=$(grep -ci addsd  "$tmp/off/k.s" || true)
mix_addpd=$(grep -ci addpd  "$tmp/mix/m.s" || true)

echo "ON  -OoVECTORIZE : addpd=$on_addpd movupd=$on_movupd"
echo "OFF             : addpd=$off_addpd addsd=$off_addsd"
echo "MIXED s/d       : addpd=$mix_addpd (must be 0)"

rc=0
[ "$on_addpd" -ge 1 ]  || { echo "FAIL: expected a packed addpd under -OoVECTORIZE"; rc=1; }
[ "$on_movupd" -ge 3 ] || { echo "FAIL: expected packed movupd loads/store under -OoVECTORIZE"; rc=1; }
[ "$off_addpd" -eq 0 ] || { echo "FAIL: unexpected packed addpd with VECTORIZE off"; rc=1; }
[ "$off_addsd" -ge 1 ] || { echo "FAIL: expected scalar addsd with VECTORIZE off"; rc=1; }
[ "$mix_addpd" -eq 0 ] || { echo "FAIL: mixed single/double loop wrongly vectorized (addpd emitted)"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: double loop packs to addpd/movupd; off stays scalar; mixed stays scalar"
exit "$rc"
