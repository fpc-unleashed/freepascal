{ %FAIL }
program prepostincdec_fail_literal_14;
{$mode unleashed}
var
  a: Integer;
begin
  // a literal is not assignable
  a := PostInc(5);
end.
