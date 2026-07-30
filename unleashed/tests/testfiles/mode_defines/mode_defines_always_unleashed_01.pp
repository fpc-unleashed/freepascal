{ %NORUN }
{ UNLEASHED identifies the compiler and is defined in every mode }
program mode_defines_always_unleashed_01;

{$mode objfpc}

{$ifndef UNLEASHED}
  {$error UNLEASHED must be defined in every mode}
{$endif}

begin
end.
