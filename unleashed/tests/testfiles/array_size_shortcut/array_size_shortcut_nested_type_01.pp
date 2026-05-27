program array_size_shortcut_nested_type_01;

{$mode unleashed}

// shortcut nested inside an explicit-range outer array
var
  ne: array[1..2] of array[10] of Byte;
  i, j: Integer;
begin
  for i := 1 to 2 do
    for j := 0 to 9 do
      ne[i][j] := Byte(i * 10 + j);
  if ne[1][0] <> 10 then halt(1);
  if ne[2][9] <> 29 then halt(2);
  if ne[1][5] <> 15 then halt(3);
end.
