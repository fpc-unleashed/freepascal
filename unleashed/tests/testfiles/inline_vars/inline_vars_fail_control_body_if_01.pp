{ %FAIL }
program inline_vars_fail_control_body_if_01;
// inline var cannot be the only statement of an if body

{$mode unleashed}

begin
  if true then var b := 2;
end.
