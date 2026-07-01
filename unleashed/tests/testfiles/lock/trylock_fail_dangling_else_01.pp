{ %FAIL }
program trylock_fail_dangling_else_01;
{$mode unleashed}

// the inner if swallows the else, leaving the trylock without one;
// wrapping the body in begin..end is the fix
var
  counter: Integer;
  cond: Boolean;
begin
  cond := true;
  trylock(counter) wait 100 do
    if cond then Inc(counter) else Dec(counter);
end.
