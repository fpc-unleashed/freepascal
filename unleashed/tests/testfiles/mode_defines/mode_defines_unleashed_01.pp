{ %NORUN }
{ mode unleashed defines FPC_UNLEASHED as its mode marker and must not
  define FPC_OBJFPC even though the mode is based on objfpc }
program mode_defines_unleashed_01;

{$mode unleashed}

{$ifndef FPC_UNLEASHED}
  {$error FPC_UNLEASHED must be defined in unleashed mode}
{$endif}
{$ifdef FPC_OBJFPC}
  {$error FPC_OBJFPC must not be defined in unleashed mode}
{$endif}

begin
end.
