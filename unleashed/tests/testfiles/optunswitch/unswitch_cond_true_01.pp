{ %OPT="-O4" }
{ Loop unswitching, condition-true path: the invariant boolean flag is hoisted
  out of the loop and the loop is cloned into a branch-free then/else pair.
  Here the flag is true, so the then-branch clone runs. The result must match
  the un-unswitched semantics.
  A runtime trip count (n) and NOAUTOINLINE keep the loop from being fully
  unrolled, so unswitching is the transform actually exercised. }
program unswitch_cond_true_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  i, acc: longint;
begin
  acc := 0;
  for i := 1 to n do
    if flag then
      acc := acc + i           { 1+2+3+4+5 = 15 }
    else
      acc := acc - i;
  work := acc;
end;

begin
  if work(5, true) <> 15 then Halt(1);
end.
