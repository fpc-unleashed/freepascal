program prepostincdec_basic_01;
{$mode unleashed}
var
  a: Integer;
begin
  a := 10;
  if PostInc(a) <> 10 then halt(1);
  if a <> 11 then halt(2);
  if PreInc(a) <> 12 then halt(3);
  if a <> 12 then halt(4);
  if PostDec(a) <> 12 then halt(5);
  if a <> 11 then halt(6);
  if PreDec(a) <> 10 then halt(7);
  if a <> 10 then halt(8);
end.
