{ %OPT="-O4" }
{ Zero-trip loop: unswitching evaluates the invariant condition once in the
  preheader, before the loop runs. Because the condition is pure and cannot
  trap (a plain boolean read), evaluating it for a zero-trip loop is safe and
  changes nothing. acc must stay at its initial value for both flag outcomes. }
program unswitch_zero_trip_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  i, acc: longint;
begin
  acc := 42;
  for i := 1 to n do           { n = 0 -> zero-trip loop }
    if flag then
      acc := acc + i
    else
      acc := acc - i;
  work := acc;
end;

begin
  if work(0, true) <> 42 then Halt(1);
  if work(0, false) <> 42 then Halt(1);
end.
