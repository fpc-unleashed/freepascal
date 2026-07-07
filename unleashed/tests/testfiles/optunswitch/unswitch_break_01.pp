{ %OPT="-O4" }
{ break inside a branch: cloning preserves it, and because the two clones are
  mutually exclusive and each is its own loop, a break inside the then-branch
  breaks its own clone's loop -- exactly as it broke the original. Here the
  then-branch breaks out at i=3. }
program unswitch_break_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  i, acc: longint;
begin
  acc := 0;
  for i := 1 to n do
    if flag then
      begin
        acc := acc + i;         { 1+2+3 then break -> 6 }
        if i = 3 then
          break;
      end
    else
      acc := acc - i;           { -(1..10) = -55 }
  work := acc;
end;

begin
  if work(10, true) <> 6 then Halt(1);
  if work(10, false) <> -55 then Halt(1);
end.
