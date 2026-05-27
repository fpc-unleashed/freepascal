program array_size_shortcut_multi_dim_01;

{$mode unleashed}

var
  m: array[3, 4] of Integer;
  i, j: Integer;
begin
  for i := 0 to 2 do
    for j := 0 to 3 do
      m[i, j] := i * 10 + j;
  if m[0, 0] <> 0 then halt(1);
  if m[2, 3] <> 23 then halt(2);
  if m[1, 2] <> 12 then halt(3);
end.
