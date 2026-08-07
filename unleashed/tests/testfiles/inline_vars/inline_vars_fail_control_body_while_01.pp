{ %FAIL }
program inline_vars_fail_control_body_while_01;
// inline var cannot be the only statement of a while body

{$mode unleashed}

begin
  while false do var b := 2;
end.
