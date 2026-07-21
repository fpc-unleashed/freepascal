{ %FAIL }
program out_var_fail_var_param_01;
{$mode unleashed}

procedure takesvar(var x: integer);
begin
  x := 1;
end;

begin
  // `var` out-capture does not apply to a var parameter (it reads on entry)
  takesvar(var y);
end.
