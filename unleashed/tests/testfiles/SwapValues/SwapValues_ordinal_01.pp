program SwapValues_ordinal_01;
{$mode unleashed}
var
  a, b: Integer;
begin
  a := 111; b := 222;
  SwapValues(a, b);
  if a <> 222 then halt(1);
  if b <> 111 then halt(2);
end.
