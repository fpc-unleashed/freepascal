program SwapValues_dynarray_10;
{$mode unleashed}
// dynamic arrays are managed: swap exchanges the array references
var
  a, b: array of Integer;
begin
  SetLength(a, 2); a[0] := 10; a[1] := 11;
  SetLength(b, 3); b[0] := 20; b[1] := 21; b[2] := 22;
  SwapValues(a, b);
  if Length(a) <> 3 then halt(1);
  if Length(b) <> 2 then halt(2);
  if a[0] <> 20 then halt(3);
  if b[0] <> 10 then halt(4);
end.
