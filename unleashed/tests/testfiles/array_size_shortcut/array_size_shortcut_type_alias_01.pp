program array_size_shortcut_type_alias_01;

{$mode unleashed}

type
  TBuf = array[10] of Integer;
  TMat = array[3, 4] of Integer;

var
  b: TBuf;
  m: TMat;
  i, j: Integer;
begin
  for i := 0 to 9 do
    b[i] := i * 2;
  if b[7] <> 14 then halt(1);

  for i := 0 to 2 do
    for j := 0 to 3 do
      m[i, j] := i + j;
  if m[2, 3] <> 5 then halt(2);
end.
