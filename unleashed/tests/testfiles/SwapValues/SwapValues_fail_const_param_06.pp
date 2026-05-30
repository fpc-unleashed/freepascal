{ %FAIL }
program SwapValues_fail_const_param_06;
{$mode unleashed}
// a const parameter is not assignable
var
  x: Integer;

procedure P(const c: Integer);
begin
  x := 1;
  SwapValues(c, x);
end;

begin
  P(5);
end.
