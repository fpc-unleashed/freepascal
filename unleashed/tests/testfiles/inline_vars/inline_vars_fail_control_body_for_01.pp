{ %FAIL }
program inline_vars_fail_control_body_for_01;
// inline var cannot be the only statement of a for body

{$mode unleashed}

begin
  for var i := 1 to 2 do var b := 2;
end.
