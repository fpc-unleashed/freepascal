{ %FAIL }
program inline_vars_fail_control_body_on_01;
// inline var cannot be the only statement of an on..do handler

{$mode unleashed}

uses sysutils;

begin
  try
    writeln;
  except
    on e: exception do var b := 2;
  end;
end.
