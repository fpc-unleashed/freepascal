{ %FAIL }
program out_var_fail_value_param_01;
{$mode unleashed}

procedure takesval(x: integer);
begin
end;

begin
  // `var` is only allowed at an out parameter, not a value parameter
  takesval(var y);
end.
