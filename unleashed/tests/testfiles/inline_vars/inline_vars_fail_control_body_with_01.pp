{ %FAIL }
program inline_vars_fail_control_body_with_01;
// inline var cannot be the only statement of a with body

{$mode unleashed}

var
  r: record
    a: integer;
  end;

begin
  with r do var b := 2;
end.
