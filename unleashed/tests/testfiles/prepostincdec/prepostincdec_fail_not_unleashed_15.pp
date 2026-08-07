{ %FAIL }
program prepostincdec_fail_not_unleashed_15;
{$mode objfpc}
var
  a: Integer;
begin
  // no prepostincdec modeswitch outside unleashed mode
  a := 0;
  a := PreInc(a);
end.
