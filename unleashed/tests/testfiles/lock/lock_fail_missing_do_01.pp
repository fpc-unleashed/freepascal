{ %FAIL }
program lock_fail_missing_do_01;
{$mode unleashed}

// the body of a lock statement is introduced by `do`
var
  counter: Integer;
begin
  lock(counter) Inc(counter);
end.
