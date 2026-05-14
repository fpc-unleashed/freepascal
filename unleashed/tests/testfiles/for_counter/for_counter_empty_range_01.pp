program for_counter_empty_range_01;

{$mode unleashed}

var
  i: Integer;

begin
  i := 999;
  for i := 10 to 1 do
    halt(2);
  // empty range, body never runs, counter unchanged
  if i <> 999 then halt(1);
end.
