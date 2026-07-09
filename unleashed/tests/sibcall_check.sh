#!/usr/bin/env bash
# Codegen assertion for -OoSIBCALL (sibling-call optimization).
#
# The runtime demo (testfiles/sibcall/) proves an even/odd mutual-recursion pair
# to depth 10^7 completes under a tiny stack with the switch and overflows
# without it. This script proves the transform actually emits a jmp to the
# sibling in the eligible case, keeps a plain call with the switch off, and
# falls back to a plain call for each disqualifier the peephole cannot prove
# safe.
#
# Usage: unleashed/tests/sibcall_check.sh [path-to-ppcx64]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
CC="${1:-$root/compiler/ppcx64}"
RTL="$root/rtl/units/x86_64-linux"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# ELIGIBLE: register-only mutual recursion; each tail call becomes a jmp.
cat > "$tmp/elig.pp" <<'EOF'
program elig;
{$mode objfpc}
function IsOdd(n: longint): boolean; forward;
function IsEven(n: longint): boolean;
begin if n=0 then IsEven:=true else IsEven:=IsOdd(n-1); end;
function IsOdd(n: longint): boolean;
begin if n=0 then IsOdd:=false else IsOdd:=IsEven(n-1); end;
begin writeln(IsEven(6)); end.
EOF

# DISQUALIFIERS: each is an otherwise-tail call the peephole must NOT convert.
cat > "$tmp/disq.pp" <<'EOF'
program disq;
{$mode objfpc}{$H+}
{ larger callee stack-arg area: 7th int arg goes on the stack }
function ManyArgs(a,b,c,d,e,f,g: longint): longint;
begin ManyArgs:=a+b+c+d+e+f+g; end;
function DQ_StackArgs(n: longint): longint;
begin DQ_StackArgs:=ManyArgs(n,n,n,n,n,n,n); end;
{ open try/finally frame }
function Helper(n: longint): longint;
begin Helper:=n+1; end;
var gsink: longint;
function DQ_Finally(n: longint): longint;
begin try DQ_Finally:=Helper(n); finally gsink:=gsink+1; end; end;
{ @local escapes into the callee }
function TakesPtr(p: pinteger): longint;
begin TakesPtr:=p^; end;
function DQ_AddrLocal(n: longint): longint;
var x: longint;
begin x:=n; DQ_AddrLocal:=TakesPtr(@x); end;
{ convention mismatch: safecall caller }
function DQ_Safecall(n: longint): longint; safecall;
begin DQ_Safecall:=Helper(n); end;
begin
  writeln(DQ_StackArgs(1), DQ_Finally(1), DQ_AddrLocal(2), DQ_Safecall(3));
end.
EOF

mkdir -p "$tmp/on" "$tmp/off" "$tmp/dq"
cp "$tmp/elig.pp" "$tmp/on/"; cp "$tmp/elig.pp" "$tmp/off/"; cp "$tmp/disq.pp" "$tmp/dq/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O2 -OoSIBCALL -al -s elig.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O2            -al -s elig.pp >/dev/null 2>&1 )
( cd "$tmp/dq"  && "$CC" -Fu"$RTL" -O2 -OoSIBCALL -al -s disq.pp >/dev/null 2>&1 )

# count tail jumps / calls to the mutual pair (exclude the top-level main call)
on_jmp=$(grep -cE 'jmp[[:space:]].*_(ISEVEN|ISODD)\$'  "$tmp/on/elig.s"  || true)
off_jmp=$(grep -cE 'jmp[[:space:]].*_(ISEVEN|ISODD)\$' "$tmp/off/elig.s" || true)

# disqualifier callees must be reached only by call, never jmp
dq_jmp=$(grep -cE 'jmp[[:space:]].*_(MANYARGS|HELPER|TAKESPTR)' "$tmp/dq/disq.s" || true)
dq_call=$(grep -cE 'call[[:space:]].*_(MANYARGS|HELPER|TAKESPTR)' "$tmp/dq/disq.s" || true)

echo "ON  eligible : sibling jmp=$on_jmp (expect 2)"
echo "OFF eligible : sibling jmp=$off_jmp (expect 0)"
echo "DQ          : sibling jmp=$dq_jmp (expect 0), plain call=$dq_call (expect >=4)"

rc=0
[ "$on_jmp"  -eq 2 ] || { echo "FAIL: eligible mutual recursion not turned into jmp under -OoSIBCALL"; rc=1; }
[ "$off_jmp" -eq 0 ] || { echo "FAIL: sibling jmp emitted without -OoSIBCALL"; rc=1; }
[ "$dq_jmp"  -eq 0 ] || { echo "FAIL: a disqualifier was sibling-call optimized"; rc=1; }
[ "$dq_call" -ge 4 ] || { echo "FAIL: disqualifiers did not all fall back to a plain call"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: eligible tail call jmp'd; switch-off and all disqualifiers keep a plain call"
exit "$rc"
