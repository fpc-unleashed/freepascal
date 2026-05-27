program array_size_shortcut_double_element_01;

{$mode unleashed}

// floating point element to confirm non-integer scalar types fit
var
  d: array[6] of Double;
  i: Integer;
  sum: Double;
begin
  for i := 0 to 5 do
    d[i] := i + 0.5;
  sum := 0;
  for i := 0 to 5 do
    sum := sum + d[i];
  // 0.5 + 1.5 + 2.5 + 3.5 + 4.5 + 5.5 = 18.0
  if Abs(sum - 18.0) > 1e-9 then halt(1);
  if Abs(d[3] - 3.5) > 1e-9 then halt(2);
end.
