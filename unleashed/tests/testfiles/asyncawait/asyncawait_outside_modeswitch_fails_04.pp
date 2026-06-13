{ %FAIL }
program asyncawait_outside_modeswitch_fails_04;
{$mode objfpc}
var x: Integer;
begin
  x := 5;
  writeln(await x);
end.
