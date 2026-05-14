program for_counter_single_iter_01;

{$mode unleashed}

var
  i: Integer;

begin
  for i := 5 to 5 do
    ;
  // single-iteration range: counter holds the only assigned value
  if i <> 5 then halt(1);
end.
