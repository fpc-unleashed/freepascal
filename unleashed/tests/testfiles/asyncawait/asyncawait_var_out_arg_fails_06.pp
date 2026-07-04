{ %FAIL }
program asyncawait_var_out_arg_fails_06;
{$mode unleashed}
uses SysUtils;
procedure bump(var x: Integer);
begin
  x := x + 1;
end;
var n: Integer;
begin
  n := 5;
  var w := async bump(n);
  await w;
end.
