{ %OPT="-O4" }
{ LICM over a while-loop body: the invariant row*width is hoisted into the
  preheader. The loop counter k is assigned in the body, so it (and anything
  derived from it) stays inside the loop. Wrong hoist would change the sum. }
program licm_while_invariant_01;
{$mode objfpc}

function work(n: longint): longint;
var
  row, width, acc, k: longint;
begin
  row := n + 3;
  width := n + 6;
  acc := 0;
  k := 0;
  while k < 5 do
    begin
      acc := acc + row * width;  { 5 * (3*6) = 5*18 = 90 }
      k := k + 1;
    end;
  work := acc;
end;

begin
  if work(0) <> 90 then Halt(1);
end.
