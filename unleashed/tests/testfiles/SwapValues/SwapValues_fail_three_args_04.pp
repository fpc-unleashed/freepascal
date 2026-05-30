{ %FAIL }
program SwapValues_fail_three_args_04;
{$mode unleashed}
// SwapValues needs exactly two arguments
var
  i, j, k: Integer;
begin
  i := 1; j := 2; k := 3;
  SwapValues(i, j, k);
end.
