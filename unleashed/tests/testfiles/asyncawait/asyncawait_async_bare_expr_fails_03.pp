{ %FAIL }
program asyncawait_async_bare_expr_fails_03;
{$mode unleashed}
var a, b: Integer;
begin
  a := 1;
  b := 2;
  var z := async (a + b);
end.
