program prepostincdec_pointer_03;
{$mode unleashed}
var
  arr: array[0..3] of Integer;
  p: PInteger;
begin
  arr[0] := 11; arr[1] := 22; arr[2] := 33; arr[3] := 44;
  p := @arr[0];
  // post: old pointer, then advanced by one element
  if PostInc(p)^ <> 11 then halt(1);
  if p^ <> 22 then halt(2);
  // pre with element count
  if PreInc(p, 2)^ <> 44 then halt(3);
  if PostDec(p, 3)^ <> 44 then halt(4);
  if p^ <> 11 then halt(5);
  if PreDec(p, -1)^ <> 22 then halt(6);
end.
