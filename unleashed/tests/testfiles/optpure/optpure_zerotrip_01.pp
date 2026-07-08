{ %OPT="-O4 -OoPURE" }
{ Hoisting a proven-const, side-effect-free, non-trapping call into the
  preheader of a loop that never executes must not change the result: the
  accumulator keeps its pre-loop value. `cube` is const and can be lifted, but
  the zero-trip loop must still contribute nothing. }
program optpure_zerotrip_01;
{$mode objfpc}

function cube(x: longint): longint;
begin
  cube := x * x * x;
end;

function work(n: longint): longint;
var
  i, k, acc: longint;
begin
  k := n + 4;
  acc := 42;
  for i := 1 to n do           { n = 0 -> zero-trip loop }
    acc := acc + cube(k);
  work := acc;
end;

begin
  if work(0) <> 42 then Halt(1);      { loop body never runs }
  if work(2) <> 42 + 2 * (6*6*6) then Halt(2);  { k=6 -> 216 twice }
end.
