program array_size_shortcut_layout_move_01;

{$mode unleashed}

// static multi-dim is contiguous - Move copies as a single block
var
  a, b: array[5, 5] of Integer;
  i, j: Integer;
begin
  for i := 0 to 4 do
    for j := 0 to 4 do
      a[i, j] := i * 100 + j;

  FillChar(b, SizeOf(b), 0);
  Move(a, b, SizeOf(a));

  for i := 0 to 4 do
    for j := 0 to 4 do
      if b[i, j] <> i * 100 + j then halt(1);
end.
