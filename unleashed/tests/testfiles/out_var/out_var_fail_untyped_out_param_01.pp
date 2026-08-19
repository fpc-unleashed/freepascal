{ %FAIL }
program out_var_fail_untyped_out_param_01;
{$mode unleashed}

procedure grab(out buf);
begin
end;

begin
  // same at an untyped out parameter: nothing to type the variable with
  grab(var y);
end.
