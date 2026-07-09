program array_literal_for_in_wide_elements_01;

{$mode unleashed}

// for..in over an int literal list with elements above 255 must infer a
// wide enough element type and iterate in source order (array, not set)
var
  n, idx, sum: integer;
  expected: array[3] of integer = (4, 1994, 3888);
begin
  idx := 0;
  for var x in [4, 1994, 3888] do
  begin
    if x <> expected[idx] then halt(1);
    inc(idx);
  end;
  if idx <> 3 then halt(2);

  // predeclared loop var takes the same array path
  idx := 0;
  for n in [4, 1994, 3888] do
  begin
    if n <> expected[idx] then halt(3);
    inc(idx);
  end;
  if idx <> 3 then halt(4);

  // elements within 0..255 keep set semantics
  sum := 0;
  for var y in [3, 1, 2] do sum := sum + y;
  if sum <> 6 then halt(5);

  // int64-range elements
  for var z in [5000000000, 1] do
    if (z <> 5000000000) and (z <> 1) then halt(6);
end.
