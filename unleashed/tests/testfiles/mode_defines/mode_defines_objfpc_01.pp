{ %NORUN }
{ mode objfpc keeps its FPC_OBJFPC marker and gets no FPC_UNLEASHED }
program mode_defines_objfpc_01;

{$mode objfpc}

{$ifndef FPC_OBJFPC}
  {$error FPC_OBJFPC must be defined in objfpc mode}
{$endif}
{$ifdef FPC_UNLEASHED}
  {$error FPC_UNLEASHED must not be defined in objfpc mode}
{$endif}

begin
end.
