{ %FAIL }
program trylock_fail_missing_else_01;
{$mode unleashed}

// a trylock can miss, so the else branch is mandatory
var
  counter: Integer;
begin
  trylock(counter) wait 100 do Inc(counter);
end.
