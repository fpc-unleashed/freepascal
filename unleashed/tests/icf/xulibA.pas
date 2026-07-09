unit xulibA;
{$mode objfpc}
interface
function CalcA(a,b,c,d: longint): longint;
implementation
function CalcA(a,b,c,d: longint): longint;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;
end.
