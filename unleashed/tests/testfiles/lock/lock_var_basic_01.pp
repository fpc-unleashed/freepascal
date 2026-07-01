program lock_var_basic_01;
{$mode unleashed}

var
  counter: Integer;

begin
  counter := 0;
  lock(counter) do Inc(counter);
  lock(counter) do Inc(counter);
  lock(counter) do Inc(counter);
  if counter <> 3 then halt(1);
end.
