{ %NORUN }
program sanity_norun_01;

{$mode unleashed}

begin
  // syntax-only check, never runs - if it ran, exitcode would be 7
  halt(7);
end.
