{ %FAIL }
program out_var_fail_seed_self_reference_01;
{$mode unleashed}

procedure twice(var a: integer);
begin
  a := a * 2;
end;

begin
  // the declared name is not yet in scope inside the seed; with no outer
  // q to fall back to, this is an unknown identifier
  twice(var q := q + 1);
end.
