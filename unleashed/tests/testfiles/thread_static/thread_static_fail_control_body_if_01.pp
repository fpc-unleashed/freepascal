{ %FAIL }
program thread_static_fail_control_body_if_01;
// threadstatic cannot be the only statement of an if body

{$mode unleashed}

procedure foo;
begin
  if true then threadstatic s := 1;
end;

begin
  foo;
end.
