program SwapValues_pointer_09;
{$mode unleashed}
type
  PInt = ^Integer;
var
  i, j: Integer;
  p, q: PInt;
begin
  i := 1; j := 2;
  p := @i; q := @j;
  SwapValues(p, q);
  if p^ <> 2 then halt(1);
  if q^ <> 1 then halt(2);
  SwapValues(p^, q^);
  if i <> 2 then halt(3);
  if j <> 1 then halt(4);
end.
