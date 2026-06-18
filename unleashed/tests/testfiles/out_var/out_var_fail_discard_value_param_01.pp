{ %FAIL }
program out_var_fail_discard_value_param_01;
{$mode unleashed}

procedure takesval(x: integer);
begin
end;

begin
  // `_` discard only applies at an out parameter, not a value parameter
  takesval(_);
end.
