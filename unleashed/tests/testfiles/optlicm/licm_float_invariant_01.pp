{ %OPT="-O4" }
{ LICM on a floating-point invariant subexpression: a*b is loop-invariant and
  is hoisted out of the accumulation loop. Result must be bit-stable. }
program licm_float_invariant_01;
{$mode objfpc}

function work(n: longint): double;
var
  i: longint;
  a, b, acc: double;
begin
  a := n + 1.5;
  b := n + 2.5;
  acc := 0;
  for i := 1 to 10 do
    acc := acc + a * b;          { 10 * (1.5*2.5) = 10*3.75 = 37.5 }
  work := acc;
end;

begin
  if Abs(work(0) - 37.5) > 1e-9 then Halt(1);
end.
