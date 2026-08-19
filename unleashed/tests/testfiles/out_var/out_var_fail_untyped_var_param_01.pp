{ %FAIL }
program out_var_fail_untyped_var_param_01;
{$mode unleashed}

procedure grab(var buf);
begin
end;

begin
  // an untyped parameter provides no type to infer for the declaration
  grab(var y);
end.
