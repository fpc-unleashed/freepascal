program forstep_downto_01;

{$mode unleashed}

var
  sum: Integer = 0;
  i: Integer;

begin
  for i := 20 downto 1 step 3 do
    sum := sum + i;
  // 20 + 17 + 14 + 11 + 8 + 5 + 2 = 77
  if sum <> 77 then halt(1);
end.
