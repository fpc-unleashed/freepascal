program forstep_to_basic_01;

{$mode unleashed}

var
  sum: Integer = 0;
  i: Integer;

begin
  for i := 1 to 10 step 2 do
    sum := sum + i;
  // 1 + 3 + 5 + 7 + 9 = 25
  if sum <> 25 then halt(1);
end.
