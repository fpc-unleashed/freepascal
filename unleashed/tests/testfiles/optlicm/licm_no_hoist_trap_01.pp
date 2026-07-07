{ %OPT="-O4" }
{ LICM must NOT hoist a trapping expression (integer division by a variable
  that is zero) out of a zero-trip loop. If it wrongly speculated the div into
  the preheader, this would raise a division-by-zero at run time even though
  the loop body never executes. Passing (exit 0) proves div is never hoisted. }
program licm_no_hoist_trap_01;
{$mode objfpc}

function work(n: longint): longint;
var
  i, y, acc: longint;
begin
  y := n;                       { n = 0, but not a compile-time constant here }
  acc := 7;
  for i := 1 to n do            { n = 0 -> zero-trip loop }
    acc := acc + (100 div y);   { would trap if executed / wrongly hoisted }
  work := acc;
end;

begin
  if work(0) <> 7 then Halt(1);
end.
