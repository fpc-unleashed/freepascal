{ %OPT="-O4" }
{ The condition depends on the loop counter, so it is NOT loop-invariant and
  must NOT be unswitched (the DFA def-set of the loop includes the counter).
  The test that varies per iteration must remain inside the loop so the result
  stays correct; a wrong unswitch would fix the branch for all iterations and
  give the wrong sum. }
program unswitch_noninvariant_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint): longint;
var
  i, acc: longint;
begin
  acc := 0;
  for i := 1 to n do
    if (i and 1) = 0 then       { true for even i: 2,4,6 -> +12 }
      acc := acc + i
    else
      acc := acc - i;           { odd i: 1,3,5 -> -9 }
  work := acc;                  { 12 - 9 = 3 }
end;

begin
  if work(6) <> 3 then Halt(1);
end.
