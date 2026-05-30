program SwapValues_float_03;
{$mode unleashed}
// swap must be a bit reinterpret, not a value conversion
var
  s1, s2: Single;
  d1, d2: Double;
begin
  s1 := 1.25; s2 := 2.5; SwapValues(s1, s2);
  if (s1 <> 2.5) or (s2 <> 1.25) then halt(1);
  d1 := 3.5; d2 := 7.25; SwapValues(d1, d2);
  if (d1 <> 7.25) or (d2 <> 3.5) then halt(2);
end.
