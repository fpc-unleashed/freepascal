program array_size_shortcut_mixed_with_range_01;

{$mode unleashed}

// shortcut size in one dim, char range in another
var
  k: array[5, 'a'..'c'] of Integer;
  i: Integer;
  c: Char;
begin
  for i := 0 to 4 do
    for c := 'a' to 'c' do
      k[i, c] := i * 100 + Ord(c);
  if k[0, 'a'] <> 97 then halt(1);
  if k[4, 'c'] <> 499 then halt(2);
  if k[2, 'b'] <> 298 then halt(3);
end.
