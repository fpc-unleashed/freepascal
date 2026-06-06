{ %FAIL }
program static_section_fail_at_program_01;
{$mode unleashed}

// section static at program top level must be rejected
static
  x: Integer = 5;

begin
  WriteLn(x);
end.
