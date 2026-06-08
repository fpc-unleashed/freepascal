{ %FAIL }
program thread_static_fail_section_at_program_14;
{$mode unleashed}

// section form is body-only, just like the inline form; at unit / program
// level a plain `threadvar` already gives the same lifetime, so this is
// rejected.
threadstatic
  x: Integer = 5;

begin
  WriteLn(x);
end.
