{ %OPT="-O4" }
{ The condition would trap if evaluated speculatively: it divides by a variable
  that is zero. Under the purity policy an integer division by a variable is not
  a pure/non-trapping invariant, so the loop must NOT be unswitched and the
  condition must stay inside the (zero-trip) loop, where it is never evaluated.
  A wrong unswitch would hoist "100 div y" into the preheader and raise a
  division-by-zero even though the loop body never runs. Exit 0 proves it does
  not unswitch. }
program unswitch_no_trap_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint): longint;
var
  i, y, acc: longint;
begin
  y := n;                       { n = 0, not a compile-time constant }
  acc := 7;
  for i := 1 to n do            { n = 0 -> zero-trip loop }
    if (100 div y) = 0 then     { would trap if speculated into the preheader }
      acc := acc + 1
    else
      acc := acc - 1;
  work := acc;
end;

begin
  if work(0) <> 7 then Halt(1);
end.
