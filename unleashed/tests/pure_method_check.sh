#!/usr/bin/env bash
# Codegen assertion for -OoPURE read-only method eligibility + -OoGVNPRE
# memory-dependent method-call commoning (task (e)).
#
# A read-only method proven pure by -OoPURE is value-numbered by -OoGVNPRE as a
# MEMORY READER: two identical calls on the same object are commoned only when
# nothing that could touch the object's state intervenes. This script proves, by
# counting the emitted call instructions, that:
#   * a by-value record-self getter called 3x with nothing between collapses to 1
#   * a class getter with an intervening FIELD WRITE stays at 2 (not commoned)
#   * a class getter with an intervening IMPURE CALL stays at 2 (not commoned)
#   * a class getter with nothing between collapses to 1 (commoned)
#   * a VIRTUAL getter is never folded (stays at 2) even with nothing between
# The runtime test testfiles/optpure/optpure_method_01.pp proves the results are
# bit-exact; this script proves the transform actually fires and is correctly
# gated. Assembly is inspected (-al -s) because instruction mnemonics cannot be
# matched by the bundled %CHECKBIN_* directive.
#
# Usage: unleashed/tests/pure_method_check.sh [path-to-ppcx64]
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
{$modeswitch advancedrecords}
type
  TP = record x, y: longint; function SumSq: longint; end;
  TC = class FV: longint; function GetV: longint; procedure Bump; end;
  TV = class FV: longint; function GetV: longint; virtual; abstract; end;
  TW = class(TV) function GetV: longint; override; end;
var glob: longint;
function TP.SumSq: longint; begin Result := x * x + y * y; end;
function TC.GetV: longint; begin Result := FV; end;
procedure TC.Bump; begin FV := FV + 1; end;
function TW.GetV: longint; begin Result := FV; end;
procedure opaque; noinline; begin glob := glob + 1; end;
function recreuse(const p: TP): longint; noinline;
var a, b: longint; begin a := p.SumSq; b := p.SumSq + p.SumSq; recreuse := a + b; end;
function fieldkill(c: TC): longint; noinline;
var x, y: longint; begin x := c.GetV; c.Bump; y := c.GetV; fieldkill := x * 1000 + y; end;
function callkill(c: TC): longint; noinline;
var x, y: longint; begin x := c.GetV; opaque; y := c.GetV; callkill := x * 1000 + y; end;
function nokill(c: TC): longint; noinline;
var x, y: longint; begin x := c.GetV; y := c.GetV; nokill := x * 1000 + y; end;
function usevirt(v: TV): longint; noinline;
var x, y: longint; begin x := v.GetV; y := v.GetV; usevirt := x * 1000 + y; end;
var p: TP; c: TC; w: TW;
begin
  p.x := 1; p.y := 2; c := TC.Create; w := TW.Create;
  writeln(recreuse(p) + fieldkill(c) + callkill(c) + nokill(c) + usevirt(w));
  c.Free; w.Free;
end.
EOF

"$CC" -Fu"$RTL" -O4 -OoPURE -OoGVNPRE -al -s "$tmp/k.pp" >/dev/null 2>&1

# count 'call' instructions between a function's label and the next .Le size marker
count_calls() { # $1=UPPER func name substring
  awk -v fn="$1" '
    $0 ~ ("_\\$\\$_" fn "[$A-Z]*:$") { inside=1; c=0; next }
    inside && /^\.Le/ { print c; inside=0 }
    inside && /call[ \t]/ { c++ }
  ' "$tmp/k.s" | head -1
}

rec=$(count_calls RECREUSE)
fk=$(count_calls FIELDKILL)
ck=$(count_calls CALLKILL)
nk=$(count_calls NOKILL)
uv=$(count_calls USEVIRT)

echo "recreuse (record getter x3, no store)   calls=$rec  (expect 1)"
echo "fieldkill (getter, field write, getter)  calls=$fk  (expect 2 GetV +1 Bump = 3)"
echo "callkill  (getter, impure call, getter)  calls=$ck  (expect 2 GetV +1 opaque = 3)"
echo "nokill    (getter, getter)               calls=$nk  (expect 1)"
echo "usevirt   (virtual getter x2)            calls=$uv  (expect 2)"

rc=0
[ "$rec" = "1" ] || { echo "FAIL: record-self getter not commoned to 1 call"; rc=1; }
[ "$fk" = "3" ]  || { echo "FAIL: getter across a field write wrongly commoned"; rc=1; }
[ "$ck" = "3" ]  || { echo "FAIL: getter across an impure call wrongly commoned"; rc=1; }
[ "$nk" = "1" ]  || { echo "FAIL: getter with nothing between not commoned to 1 call"; rc=1; }
[ "$uv" = "2" ]  || { echo "FAIL: virtual getter wrongly folded"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: read-only method commons only when object state provably unchanged; virtual never folded"
exit "$rc"
