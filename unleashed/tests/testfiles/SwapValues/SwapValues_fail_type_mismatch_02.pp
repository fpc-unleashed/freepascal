{ %FAIL }
program SwapValues_fail_type_mismatch_02;
{$mode unleashed}
// operands must be the same type
var
  i: Integer;
  s: AnsiString;
begin
  i := 1; s := 'x';
  SwapValues(i, s);
end.
