program for_counter_natural_exit_01;

{$mode unleashed}

var
  i: Integer;

begin
  for i := 1 to 10 do
    ;
  // unleashed mode: counter keeps last in-range value (10)
  if i <> 10 then halt(1);
end.
