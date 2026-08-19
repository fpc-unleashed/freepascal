{ %FAIL }
program out_var_fail_seed_out_param_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 42;
end;

begin
  // a seed is meaningless for an out parameter (the callee never reads it),
  // so a seeded declaration is rejected there
  getval(var y := 5);
end.
