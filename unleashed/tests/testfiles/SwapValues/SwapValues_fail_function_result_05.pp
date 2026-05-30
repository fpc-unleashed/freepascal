{ %FAIL }
program SwapValues_fail_function_result_05;
{$mode unleashed}
// a function result is not assignable
var
  i: Integer;

function F: Integer;
begin
  Result := 3;
end;

begin
  i := 1;
  SwapValues(F, i);
end.
