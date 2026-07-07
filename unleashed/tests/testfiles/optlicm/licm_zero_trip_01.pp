{ %OPT="-O4" }
{ LICM: hoisting a pure, exception-free invariant into the preheader of a
  loop that never executes must not change the result. The invariant
  row*width is lifted out but the accumulator keeps its pre-loop value. }
program licm_zero_trip_01;
{$mode objfpc}

function work(n: longint): longint;
var
  i, row, width, acc: longint;
begin
  row := n + 5;
  width := n + 7;
  acc := 99;
  for i := 1 to n do            { n = 0 -> zero-trip loop }
    acc := acc + row * width;
  work := acc;
end;

begin
  if work(0) <> 99 then Halt(1);
end.
