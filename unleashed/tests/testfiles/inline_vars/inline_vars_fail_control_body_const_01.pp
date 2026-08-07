{ %FAIL }
program inline_vars_fail_control_body_const_01;
// inline const cannot be the only statement of an if body

{$mode unleashed}

begin
  if true then const k = 2;
end.
