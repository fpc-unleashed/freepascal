{ %FAIL }
program out_var_fail_collision_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 1;
end;

var
  existing: integer;
begin
  existing := 0;
  // declaring `var existing` collides with the already-declared variable
  getval(var existing);
end.
