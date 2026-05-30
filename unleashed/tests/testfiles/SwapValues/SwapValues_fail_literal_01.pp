{ %FAIL }
program SwapValues_fail_literal_01;
{$mode unleashed}
// a literal is not assignable
var
  i: Integer;
begin
  i := 1;
  SwapValues(5, i);
end.
