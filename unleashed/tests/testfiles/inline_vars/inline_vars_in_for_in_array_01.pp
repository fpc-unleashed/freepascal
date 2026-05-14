program inline_vars_in_for_in_array_01;

{$mode unleashed}

begin
  var sum := 0;
  for var x in [10, 20, 30, 40] do
    sum := sum + x;
  if sum <> 100 then halt(1);
end.
