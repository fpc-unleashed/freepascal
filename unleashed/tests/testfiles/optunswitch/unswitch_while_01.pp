{ %OPT="-O4" }
{ Unswitching a while-loop body (twhilerepeatnode). The counter k is assigned
  in the body so it stays inside; the invariant flag is hoisted and the loop is
  cloned into branch-free variants. }
program unswitch_while_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  k, acc: longint;
begin
  acc := 0;
  k := 0;
  while k < n do
    begin
      if flag then
        acc := acc + 10
      else
        acc := acc + 1;
      k := k + 1;
    end;
  work := acc;
end;

begin
  if work(5, true) <> 50 then Halt(1);
  if work(5, false) <> 5 then Halt(1);
end.
