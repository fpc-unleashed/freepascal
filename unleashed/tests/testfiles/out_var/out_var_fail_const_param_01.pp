{ %FAIL }
program out_var_fail_const_param_01;
{$mode unleashed}

procedure takesconst(const x: integer);
begin
end;

begin
  // `var` out-capture does not apply to a const parameter
  takesconst(var y);
end.
