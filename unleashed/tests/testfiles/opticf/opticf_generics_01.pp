{ %OPT="-O2 -OoICF" }
{ ICF on the motivating case: two specializations of the same generic method
  over the same element type produce structurally (and here byte-) identical
  code.  ICF folds the duplicate instantiation into a thunk while both
  specializations keep distinct addresses and correct behaviour.  This is the
  "generics make binaries duplicate-heavy" scenario the pass targets. }
program opticf_generics_01;
{$mode objfpc}{$H+}

type
  generic TBox<T> = object
    function Blend(const a,b,c,d: T): T;
  end;

function TBox.Blend(const a,b,c,d: T): T;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

type
  TBoxA = specialize TBox<longint>;
  TBoxB = specialize TBox<longint>;

var
  ba: TBoxA;
  bb: TBoxB;
  ra, rb: longint;
begin
  ra := ba.Blend(2,3,4,5);
  rb := bb.Blend(2,3,4,5);
  { same element type, same body -> same result }
  if ra <> rb then Halt(1);
  Writeln('OK');
end.
