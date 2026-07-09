{ %OPT="-O2 -OoSIBCALL" }
{ -OoSIBCALL must fall back to a plain call for cases it cannot prove safe and
  keep semantics identical: a callee with a stack-argument area, an open
  try/finally frame, a routine passing @local into the callee, and a safecall
  (convention-mismatch) caller. Correctness only -- the codegen fallback itself
  is asserted by unleashed/tests/sibcall_check.sh. }
program sibcall_disqualifiers_01;
{$mode objfpc}{$H+}

function ManyArgs(a,b,c,d,e,f,g: longint): longint;
begin ManyArgs:=a+b+c+d+e+f+g; end;
function DQ_StackArgs(n: longint): longint;
begin DQ_StackArgs:=ManyArgs(n,n,n,n,n,n,n); end;

function Helper(n: longint): longint;
begin Helper:=n+1; end;

var gsink: longint;
function DQ_Finally(n: longint): longint;
begin
  try DQ_Finally:=Helper(n); finally gsink:=gsink+1; end;
end;

function TakesPtr(p: pinteger): longint;
begin TakesPtr:=p^; end;
function DQ_AddrLocal(n: longint): longint;
var x: longint;
begin x:=n; DQ_AddrLocal:=TakesPtr(@x); end;

function DQ_Safecall(n: longint): longint; safecall;
begin DQ_Safecall:=Helper(n); end;

begin
  if DQ_StackArgs(3)<>21 then Halt(1);
  gsink:=0;
  if DQ_Finally(10)<>11 then Halt(2);
  if gsink<>1 then Halt(3);
  if DQ_AddrLocal(7)<>7 then Halt(4);
  if DQ_Safecall(41)<>42 then Halt(5);
end.
