program SwapValues_array_elems_08;
{$mode unleashed}
var
  a: array[0..3] of Integer;
begin
  a[0] := 5; a[1] := 6; a[2] := 7; a[3] := 8;
  SwapValues(a[0], a[3]);
  if a[0] <> 8 then halt(1);
  if a[3] <> 5 then halt(2);
  if (a[1] <> 6) or (a[2] <> 7) then halt(3);
end.
