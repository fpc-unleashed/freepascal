program for_counter_int64_01;

{$mode unleashed}

// Int64 loop counters compile on 32-bit targets too (for loops lower
// to while loops, whose 64-bit arithmetic works everywhere)
var
  i, total: int64;
  steps: integer;
begin
  steps := 0;
  for i := 0 to 5 do inc(steps);
  if steps <> 6 then halt(1);

  for var j: Int64 := 1 to 3 do
    if (j < 1) or (j > 3) then halt(2);

  // range crossing the 32-bit boundary
  total := 0;
  for var k: Int64 := 4294967294 to 4294967297 do total := total + 1;
  if total <> 4 then halt(3);

  for var d := Int64(2) downto 0 do
    if (d < 0) or (d > 2) then halt(4);
end.
