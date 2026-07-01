program lock_callsite_block_01;
{$mode unleashed}

var
  counter: Integer;

begin
  counter := 0;
  lock do begin
    Inc(counter);
    Inc(counter);
    Inc(counter);
  end;
  if counter <> 3 then halt(1);
end.
