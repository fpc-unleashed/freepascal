{ %OPT="-O4" }
{ Nested loops: the invariant "if flag" lives in the inner loop, and flag is
  invariant with respect to it. Postorder processing unswitches the inner loop
  (innermost first). The doubly-nested accumulation must stay correct for both
  flag outcomes. Runtime bounds keep the loops from being fully unrolled. }
program unswitch_nested_inner_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(m, n: longint; flag: boolean): longint;
var
  i, j, acc: longint;
begin
  acc := 0;
  for j := 1 to m do
    for i := 1 to n do
      if flag then
        acc := acc + (j * i)    { flag true }
      else
        acc := acc - (j * i);
  work := acc;
end;

begin
  { sum_{j=1..3} sum_{i=1..4} j*i = (1+2+3)*(1+2+3+4) = 6*10 = 60 }
  if work(3, 4, true) <> 60 then Halt(1);
  if work(3, 4, false) <> -60 then Halt(1);
end.
