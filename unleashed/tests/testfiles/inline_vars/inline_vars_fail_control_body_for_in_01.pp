{ %FAIL }
program inline_vars_fail_control_body_for_in_01;
// inline var cannot be the only statement of a for-in body

{$mode unleashed}

begin
  for var x in [1, 2] do var b := 2;
end.
