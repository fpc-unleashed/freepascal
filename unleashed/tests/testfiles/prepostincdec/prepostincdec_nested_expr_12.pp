program prepostincdec_nested_expr_12;
{$mode unleashed}
var
  a, b: Integer;
  arr: array[0..4] of Integer;
  i: Integer;
begin
  a := 5;
  b := 3 * PostInc(a) + PreInc(a);
  if b <> 22 then halt(1);
  if a <> 7 then halt(2);
  // as an index expression
  for i := 0 to 4 do arr[i] := i * 10;
  a := 1;
  if arr[PostInc(a)] <> 10 then halt(3);
  if arr[PreInc(a)] <> 30 then halt(4);
  // chained on the same variable inside one call
  a := 0;
  if PostInc(a) + PostInc(a) + PostInc(a) <> 3 then halt(5);
  if a <> 3 then halt(6);
end.
