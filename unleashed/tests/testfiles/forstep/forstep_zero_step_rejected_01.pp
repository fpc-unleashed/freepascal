{ %FAIL }
program forstep_zero_step_rejected_01;

{$mode unleashed}

begin
  // step must be positive (> 0); zero would be an infinite loop
  for var i := 1 to 10 step 0 do
    WriteLn(i);
end.
