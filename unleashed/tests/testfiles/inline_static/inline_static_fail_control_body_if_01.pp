{ %FAIL }
program inline_static_fail_control_body_if_01;
// inline static cannot be the only statement of an if body

{$mode unleashed}

procedure foo;
begin
  if true then static s := 1;
end;

begin
  foo;
end.
