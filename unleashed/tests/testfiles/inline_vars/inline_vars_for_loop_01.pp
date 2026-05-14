program inline_vars_for_loop_01;

{$mode unleashed}

var
  total: Integer;

begin
  total := 0;
  for var i := 1 to 10 do
    total := total + i;
  if total <> 55 then halt(1);
end.
