{ %OPT="-O4" }
{ LICM: an invariant multiplication inside a nested loop must be hoisted
  without changing the result. Fails (wrong sum) if the hoist is miscompiled. }
program licm_nested_mul_01;
{$mode objfpc}

function work(n: longint): longint;
var
  i, j, row, width, acc: longint;
begin
  row := n + 5;
  width := n + 7;
  acc := 0;
  for i := 1 to 3 do
    for j := 1 to 4 do
      acc := acc + row * width;   { 3*4*(5*7) = 12*35 = 420 }
  work := acc;
end;

begin
  if work(0) <> 420 then Halt(1);
end.
