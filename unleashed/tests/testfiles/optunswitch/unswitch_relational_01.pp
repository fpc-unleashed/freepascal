{ %OPT="-O4" }
{ The condition is a relational comparison of two loop-invariant operands
  (stride = 1), which is pure and non-trapping, so it qualifies for
  unswitching just like a plain boolean flag. Result must be preserved for
  both outcomes of the comparison. }
program unswitch_relational_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n, stride: longint): longint;
var
  i, acc: longint;
begin
  acc := 0;
  for i := 1 to n do
    if stride = 1 then
      acc := acc + i            { fast path }
    else
      acc := acc + i * stride;
  work := acc;
end;

begin
  if work(5, 1) <> 15 then Halt(1);        { 1+2+3+4+5 }
  if work(5, 2) <> 30 then Halt(1);        { 2*(1+2+3+4+5) }
end.
