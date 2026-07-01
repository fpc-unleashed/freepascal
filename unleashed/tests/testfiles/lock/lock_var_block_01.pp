program lock_var_block_01;
{$mode unleashed}

var
  counter: Integer;
  sum: Integer;

begin
  counter := 0;
  sum := 0;
  lock(counter) do begin
    Inc(counter);
    Inc(counter);
    sum := sum + counter;
  end;
  if counter <> 2 then halt(1);
  if sum <> 2 then halt(2);
end.
