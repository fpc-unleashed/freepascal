{ %FAIL }
program inline_vars_fail_control_body_if_else_01;
// inline var cannot be the only statement of an else branch

{$mode unleashed}

begin
  if true then writeln else var b := 2;
end.
