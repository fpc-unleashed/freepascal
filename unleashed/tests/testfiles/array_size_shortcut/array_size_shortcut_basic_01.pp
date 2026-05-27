program array_size_shortcut_basic_01;

{$mode unleashed}

var
  a: array[10] of Integer;
  i, sum: Integer;
begin
  for i := 0 to 9 do
    a[i] := i + 1;
  sum := 0;
  for i := 0 to 9 do
    sum := sum + a[i];
  if sum <> 55 then halt(1);
end.
