{ %FAIL }
program trylock_fail_negative_wait_01;
{$mode unleashed}

// a negative constant wait budget is meaningless
var
  counter: Integer;
begin
  trylock(counter) wait -5 do Inc(counter) else ;
end.
