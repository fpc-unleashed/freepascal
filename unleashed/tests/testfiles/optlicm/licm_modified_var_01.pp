{ %OPT="-O4" }
{ LICM: an expression is NOT invariant if one of its operands is assigned
  inside the loop. Here width changes every iteration, so row*width must be
  recomputed. A wrong hoist (reading width once) would give 140 instead of 170. }
program licm_modified_var_01;
{$mode objfpc}

function work(n: longint): longint;
var
  i, row, width, acc: longint;
begin
  row := n + 5;
  width := n + 7;               { starts at 7 }
  acc := 0;
  for i := 1 to 4 do
    begin
      acc := acc + row * width; { 5*7 + 5*8 + 5*9 + 5*10 = 35+40+45+50 = 170 }
      width := width + 1;
    end;
  work := acc;
end;

begin
  if work(0) <> 170 then Halt(1);
end.
