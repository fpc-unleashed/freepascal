program zeroinit_function_result_03;

{$mode unleashed}

function Accumulate: Integer; zeroinit;
var
  acc: Integer;
  i: Integer;
begin
  for i := 1 to 5 do
    Inc(acc);
  Result := acc;
end;

begin
  if Accumulate <> 5 then halt(1);
  if Accumulate <> 5 then halt(2);
end.
