unit xulibB;
{$mode objfpc}
interface
function CalcB(a,b,c,d: longint): longint;
function CalcBdiff(a,b,c,d: longint): longint;
implementation
uses xulibA;
{ byte-identical to xulibA.CalcA -> folds cross-unit into a jmp thunk to CalcA }
function CalcB(a,b,c,d: longint): longint;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;
{ differs by one op -> must NOT fold }
function CalcBdiff(a,b,c,d: longint): longint;
begin
  result:=a*b+c-d; result:=result*c; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;
end.
