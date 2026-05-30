{ %FAIL }
program SwapValues_fail_one_arg_03;
{$mode unleashed}
// SwapValues needs exactly two arguments
var
  i: Integer;
begin
  i := 1;
  SwapValues(i);
end.
