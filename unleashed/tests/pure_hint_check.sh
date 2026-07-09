#!/usr/bin/env bash
# Diagnostic assertion for the -OoPURE -vh purity hints (task (d)).
#
# -OoPURE emits, once per analyzed routine and gated at hint verbosity (-vh),
# a hint reporting the discovered verdict:
#   "Function ... proven const by -OoPURE"  (result depends only on by-value args)
#   "Function ... proven pure by -OoPURE"   (reads state but never writes it)
# This script proves the hint fires with the right flavour for a const function,
# a pure-but-not-const function (reads a global) and a pure read-only method, and
# does NOT fire for an impure routine (writes a global) nor when -OoPURE is off.
#
# Usage: unleashed/tests/pure_hint_check.sh [path-to-ppcx64]
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
type TP = record x: longint; function Sq: longint; end;
var glob: longint;
function TP.Sq: longint; begin Result := x * x; end;    { pure method }
function cst(a: longint): longint; begin cst := a * a - 1; end;   { const }
function pur(a: longint): longint; begin pur := a + glob; end;    { pure }
function imp(a: longint): longint; begin glob := a; imp := a; end;{ impure }
var p: TP;
begin p.x := 3; glob := 1; writeln(cst(2) + pur(2) + imp(2) + p.Sq); end.
EOF

on="$("$CC" -Fu"$RTL" -O2 -OoPURE -vh "$tmp/k.pp" 2>&1 || true)"
off="$("$CC" -Fu"$RTL" -O2 -vh "$tmp/k.pp" 2>&1 || true)"

echo "--- with -OoPURE -vh ---"; echo "$on" | grep -iE "proven (pure|const)" || true

rc=0
grep -qE 'Function "cst[^"]*" proven const' <<<"$on" || { echo "FAIL: cst not reported const"; rc=1; }
grep -qE 'Function "pur[^"]*" proven pure'  <<<"$on" || { echo "FAIL: pur not reported pure";  rc=1; }
grep -qE 'Function "Sq[^"]*" proven pure'   <<<"$on" || { echo "FAIL: read-only method Sq not reported pure"; rc=1; }
grep -qE 'imp[^"]*" proven'                 <<<"$on" && { echo "FAIL: impure imp wrongly reported pure/const"; rc=1; } || true
grep -qE 'proven (pure|const)'              <<<"$off" && { echo "FAIL: hint emitted without -OoPURE"; rc=1; } || true

[ "$rc" -eq 0 ] && echo "PASS: -vh reports const/pure/method verdicts; silent for impure and with -OoPURE off"
exit "$rc"
