{ %FAIL }
{ test multi-var init: must fail without modeswitch }
{$mode objfpc}

var
  a, b: integer = 42;

begin
  halt(1);
end.
