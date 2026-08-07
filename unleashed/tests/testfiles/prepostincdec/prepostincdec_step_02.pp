program prepostincdec_step_02;
{$mode unleashed}
var
  a: Integer;
  q: QWord;
begin
  a := 100;
  if PostInc(a, 5) <> 100 then halt(1);
  if a <> 105 then halt(2);
  if PreInc(a, 5) <> 110 then halt(3);
  if PostDec(a, 10) <> 110 then halt(4);
  if a <> 100 then halt(5);
  if PreDec(a, 10) <> 90 then halt(6);
  // negative step
  if PreInc(a, -40) <> 50 then halt(7);
  if PostDec(a, -25) <> 50 then halt(8);
  if a <> 75 then halt(9);
  // 64 bit unsigned
  q := QWord($FFFFFFFFFFFFFFFE);
  if PreInc(q) <> QWord($FFFFFFFFFFFFFFFF) then halt(10);
  if PostDec(q, 3) <> QWord($FFFFFFFFFFFFFFFF) then halt(11);
  if q <> QWord($FFFFFFFFFFFFFFFC) then halt(12);
end.
