program SwapValues_record_06;
{$mode unleashed}
// 12-byte record: swapped through the byte-array path
type
  TRec = record a, b, c: Integer; end;
var
  r1, r2: TRec;
begin
  r1.a := 1; r1.b := 2; r1.c := 3;
  r2.a := 4; r2.b := 5; r2.c := 6;
  SwapValues(r1, r2);
  if (r1.a <> 4) or (r1.b <> 5) or (r1.c <> 6) then halt(1);
  if (r2.a <> 1) or (r2.b <> 2) or (r2.c <> 3) then halt(2);
end.
