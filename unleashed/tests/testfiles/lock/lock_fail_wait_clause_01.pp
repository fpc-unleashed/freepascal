{ %FAIL }
program lock_fail_wait_clause_01;
{$mode unleashed}

// `lock` always blocks - a bounded acquisition is spelled `trylock ... wait`
var
  counter: Integer;
begin
  lock(counter) wait 100 do Inc(counter);
end.
