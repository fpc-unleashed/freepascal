program forstep_step_evaluated_once_01;

{$mode unleashed}

var
  call_count: Integer = 0;

function StepValue: Integer;
begin
  Inc(call_count);
  Result := 3;
end;

begin
  for var i := 1 to 20 step StepValue do
    ;
  // step expression evaluated exactly once before the loop
  if call_count <> 1 then halt(1);
end.
