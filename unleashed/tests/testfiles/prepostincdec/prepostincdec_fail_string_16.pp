{ %FAIL }
program prepostincdec_fail_string_16;
{$mode unleashed}
var
  s: AnsiString;
begin
  // no inc/dec on a string
  s := 'x';
  s := PreInc(s);
end.
