{ %OPT="-O3 -Oodeadstore" }
{ Regression: enabling -Oodeadstore at -O3 runs opttree.normalize, which used to
  hoist a statement/if-expression block out of a surrounding loop body (it
  carried the outer statement as the hoist target while descending into the loop
  body). The if-expression was then evaluated ONCE before the loop with a stale
  counter, so every iteration saw the same value. Here the first iteration (n=0)
  must take the THEN branch; the bug made it always take the ELSE branch. }
program dsnorm_ifexpr_in_loop_01;
{$mode unleashed}
var
  n: longint;
  seen: string;
begin
  for n := 0 to 4 do
  begin
    var s := if n = 0 then 'zero'
             else if n mod 2 = 0 then 'even'
             else 'odd';
    case n of
      0:       if s <> 'zero' then Halt(1);
      2, 4:    if s <> 'even' then Halt(2);
      1, 3:    if s <> 'odd'  then Halt(3);
    end;
    seen := seen + s + ';';
  end;
  if seen <> 'zero;odd;even;odd;even;' then Halt(4);
end.
