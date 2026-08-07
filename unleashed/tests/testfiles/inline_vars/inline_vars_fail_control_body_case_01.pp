{ %FAIL }
program inline_vars_fail_control_body_case_01;
// inline var cannot be the only statement of a case branch

{$mode unleashed}

var
  x: integer;

begin
  x := 1;
  case x of
    1: var b := 2;
  end;
end.
