{ %FAIL }
program thread_static_fail_tstatic_section_at_program_22;
{$mode unleashed}

// `tstatic` is the `threadstatic` alias and is equally a body-only form;
// a section at program level has no body to attach to
tstatic
  x: Integer = 5;

begin
end.
