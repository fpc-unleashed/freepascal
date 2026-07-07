{ %OPT="-O4" }
{ Loop unswitching, condition-false path: same shape as the true case, but the
  invariant flag is false, so the else-branch clone runs. The specialised
  branch-free clone must preserve the original semantics. }
program unswitch_cond_false_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  i, acc: longint;
begin
  acc := 0;
  for i := 1 to n do
    if flag then
      acc := acc + i
    else
      acc := acc - i;          { -(1+2+3+4+5) = -15 }
  work := acc;
end;

begin
  if work(5, false) <> -15 then Halt(1);
end.
