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
function ManyArgsV(const a: array of const): longint;
begin ManyArgsV:=High(a)+1; end;
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
{ compiler-generated temp (open array of const) whose address escapes to the
  callee -- NOT tracked by addr_taken; rejected by the frame-address scan }
function DQ_OpenArray(n: longint): longint;
begin DQ_OpenArray:=ManyArgsV([n,n,n]); end;
begin
  writeln(DQ_StackArgs(1), DQ_Finally(1), DQ_AddrLocal(2), DQ_Safecall(3), DQ_OpenArray(4));
end.
EOF

# FORWARD: result forwarded through more than one location.
#  - a 128-bit record result (rax:rdx) staged through two frame slots, and
#  - a longint result forwarded through a single callee-saved register.
# Both mutual-recursion pairs must become jmps under -OoSIBCALL.
# NOT-PURE-FORWARD negative: the result is modified after the call
# (Result := Callee(n)+1), so it is not a tail call and must keep a plain call.
cat > "$tmp/fwd.pp" <<'EOF'
program fwd;
{$mode objfpc}{$H+}
type TPair = record a, b: int64; end;
function OddP(n: longint): TPair; forward;
function EvenP(n: longint): TPair;
var loc: array[0..3] of longint; i: longint;
begin
  for i:=0 to 3 do loc[i]:=n+i;
  if n=0 then begin EvenP.a:=loc[0]; EvenP.b:=loc[1]; end else EvenP:=OddP(n-1);
end;
function OddP(n: longint): TPair;
var loc: array[0..3] of longint; i: longint;
begin
  for i:=0 to 3 do loc[i]:=n-i;
  if n=0 then begin OddP.a:=loc[0]; OddP.b:=loc[1]; end else OddP:=EvenP(n-1);
end;
function Bounce(n: longint): longint; forward;
function Ping(n: longint): longint;
var a: array[0..7] of longint; i, keep: longint;
begin
  keep:=n*3+1; for i:=0 to 7 do a[i]:=n+i;
  if n=0 then Ping:=keep+a[0] else Ping:=Bounce(n-1);
end;
function Bounce(n: longint): longint;
var a: array[0..7] of longint; i, keep: longint;
begin
  keep:=n+9; for i:=0 to 7 do a[i]:=n-i;
  if n=0 then Bounce:=keep+a[0] else Bounce:=Ping(n-1);
end;
{ NOT a tail call: result altered after the call, so no pure forwarding }
function NP_Inner(n: longint): longint;
begin NP_Inner:=n+1; end;
function NP_Add1(n: longint): longint;
begin NP_Add1:=NP_Inner(n)+1; end;
var p: TPair;
begin
  p:=EvenP(6); writeln(p.a, p.b, Ping(6), NP_Add1(3));
end.
EOF

mkdir -p "$tmp/on" "$tmp/off" "$tmp/dq" "$tmp/fwd"
cp "$tmp/elig.pp" "$tmp/on/"; cp "$tmp/elig.pp" "$tmp/off/"; cp "$tmp/disq.pp" "$tmp/dq/"; cp "$tmp/fwd.pp" "$tmp/fwd/"
( cd "$tmp/on"  && "$CC" -Fu"$RTL" -O2 -OoSIBCALL -al -s elig.pp >/dev/null 2>&1 )
( cd "$tmp/off" && "$CC" -Fu"$RTL" -O2            -al -s elig.pp >/dev/null 2>&1 )
( cd "$tmp/dq"  && "$CC" -Fu"$RTL" -O2 -OoSIBCALL -al -s disq.pp >/dev/null 2>&1 )
( cd "$tmp/fwd" && "$CC" -Fu"$RTL" -O2 -OoSIBCALL -al -s fwd.pp >/dev/null 2>&1 )

# count tail jumps / calls to the mutual pair (exclude the top-level main call)
on_jmp=$(grep -cE 'jmp[[:space:]].*_(ISEVEN|ISODD)\$'  "$tmp/on/elig.s"  || true)
off_jmp=$(grep -cE 'jmp[[:space:]].*_(ISEVEN|ISODD)\$' "$tmp/off/elig.s" || true)

# disqualifier callees must be reached only by call, never jmp
dq_jmp=$(grep -cE 'jmp[[:space:]].*_(MANYARGS|MANYARGSV|HELPER|TAKESPTR)' "$tmp/dq/disq.s" || true)
dq_call=$(grep -cE 'call[[:space:]].*_(MANYARGS|MANYARGSV|HELPER|TAKESPTR)' "$tmp/dq/disq.s" || true)

# multi-location forwarding: both mutual pairs become jmps (2 pairs -> 4 jmps)
fwd_jmp=$(grep -cE 'jmp[[:space:]].*_(EVENP|ODDP|PING|BOUNCE)\$' "$tmp/fwd/fwd.s" || true)
# not-pure-forward: NP_Add1 modifies the result after the call -> keep a call
np_jmp=$(grep -cE 'jmp[[:space:]].*_NP_INNER\$'  "$tmp/fwd/fwd.s" || true)
np_call=$(grep -cE 'call[[:space:]].*_NP_INNER\$' "$tmp/fwd/fwd.s" || true)

echo "ON  eligible : sibling jmp=$on_jmp (expect 2)"
echo "OFF eligible : sibling jmp=$off_jmp (expect 0)"
echo "DQ          : sibling jmp=$dq_jmp (expect 0), plain call=$dq_call (expect >=5)"
echo "FWD         : multi-loc forward jmp=$fwd_jmp (expect 4)"
echo "NOT-FWD     : non-tail jmp=$np_jmp (expect 0), plain call=$np_call (expect >=1)"

rc=0
[ "$on_jmp"  -eq 2 ] || { echo "FAIL: eligible mutual recursion not turned into jmp under -OoSIBCALL"; rc=1; }
[ "$off_jmp" -eq 0 ] || { echo "FAIL: sibling jmp emitted without -OoSIBCALL"; rc=1; }
[ "$dq_jmp"  -eq 0 ] || { echo "FAIL: a disqualifier was sibling-call optimized"; rc=1; }
[ "$dq_call" -ge 5 ] || { echo "FAIL: disqualifiers did not all fall back to a plain call"; rc=1; }
[ "$fwd_jmp" -eq 4 ] || { echo "FAIL: multi-location result forwarding not turned into jmp under -OoSIBCALL"; rc=1; }
[ "$np_jmp"  -eq 0 ] || { echo "FAIL: a non-tail call (result modified after call) was sibling-call optimized"; rc=1; }
[ "$np_call" -ge 1 ] || { echo "FAIL: non-tail call did not keep a plain call"; rc=1; }

[ "$rc" -eq 0 ] && echo "PASS: eligible/multi-location tail calls jmp'd; switch-off, disqualifiers and non-tail calls keep a plain call"
exit "$rc"
