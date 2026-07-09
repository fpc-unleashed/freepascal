{ %OPT="-O2 -OoICF" }
{ Symbol-alias mode of -OoICF.  Foo and Bar are byte-identical AND their
  addresses are never taken as a value anywhere, so ICF may collapse the
  duplicate to a *zero byte* symbol alias (an extra label at the survivor's
  address) instead of a 5-byte jmp thunk -- @Foo/@Bar can never be observed, so
  making them share an address is unobservable.  Baz differs by one operation
  and must not fold.  This test only asserts runtime correctness (that the
  aliasing/folding does not corrupt behaviour); the zero-byte-alias assembly
  shape itself is asserted by unleashed/tests/icf_check.sh, which cannot be done
  from within the program without taking @Foo (which would force the thunk). }
program opticf_alias_01;
{$mode objfpc}

function Foo(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

function Bar(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

function Baz(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*c; result:=result xor b;   { *c not *a }
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

var
  rf, rb, rz: longint;
begin
  rf:=Foo(2,3,4,5);
  rb:=Bar(2,3,4,5);
  rz:=Baz(2,3,4,5);
  if rf<>rb then Halt(1);   { identical bodies -> identical result }
  if rz=rf then Halt(2);    { Baz differs -> different result }
  Writeln('OK');
end.
