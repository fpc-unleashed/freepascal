{ %OPT=-Cr }
program prepostincdec_rangecheck_13;
{$mode unleashed}
var
  b: Byte;
begin
  b := 254;
  // stays in range under -Cr
  if PostInc(b) <> 254 then halt(1);
  if b <> 255 then halt(2);
  if PreDec(b, 255) <> 0 then halt(3);
end.
