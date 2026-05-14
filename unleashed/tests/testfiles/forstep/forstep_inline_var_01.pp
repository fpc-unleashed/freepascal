program forstep_inline_var_01;

{$mode unleashed}

var
  sum: Integer = 0;

begin
  for var k := 5 to 50 step 5 do
    sum := sum + k;
  // 5 + 10 + 15 + 20 + 25 + 30 + 35 + 40 + 45 + 50 = 275
  if sum <> 275 then halt(1);
end.
