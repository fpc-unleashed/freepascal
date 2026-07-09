{ %OPT="-O2 -OoSIBCALL" }
{ -OoSIBCALL sibling-call optimization: an even/odd mutual-recursion pair whose
  tail calls become jmps (frame reuse), so a large depth runs in O(1) stack and
  still returns the correct parity. Results must be identical to a plain call. }
program sibcall_evenodd_01;
{$mode objfpc}{$H+}

function IsOdd(n: longint): boolean; forward;

function IsEven(n: longint): boolean;
begin
  if n=0 then IsEven:=true
  else IsEven:=IsOdd(n-1);
end;

function IsOdd(n: longint): boolean;
begin
  if n=0 then IsOdd:=false
  else IsOdd:=IsEven(n-1);
end;

{ continuation-style dispatch that forwards an accumulator result through the
  tail call chain -- exercises the result-forwarded-through-callee-saved shape }
function SumUp(n, acc: longint): longint;
begin
  if n=0 then SumUp:=acc
  else SumUp:=SumUp(n-1, acc+n);
end;

begin
  if IsEven(1000000)<>true  then Halt(1);
  if IsOdd(1000000)<>false  then Halt(2);
  if IsEven(999999)<>false  then Halt(3);
  if IsOdd(999999)<>true    then Halt(4);
  { 1+2+...+5000 = 12502500 }
  if SumUp(5000,0)<>12502500 then Halt(5);
end.
