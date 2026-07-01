{ %FAIL }
program trylock_fail_missing_do_01;
{$mode unleashed}

// the body of a trylock statement is introduced by `do`
var
  counter: Integer;
begin
  trylock(counter) Inc(counter) else ;
end.
