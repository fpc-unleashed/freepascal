program lock_callsite_basic_01;
{$mode unleashed}

var
  counter: Integer;

begin
  counter := 0;
  lock do Inc(counter);
  lock do Inc(counter);
  if counter <> 2 then halt(1);
end.
