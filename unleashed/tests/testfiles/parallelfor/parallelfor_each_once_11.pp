program parallelfor_each_once_11;
{$mode unleashed}
uses SysUtils;
// every index is dispatched exactly once: each slot ends at 1
const N = 1000;
var hit: array[1..N] of Integer;
    i: Integer;
begin
  for i := 1 to N do hit[i] := 0;
  for parallel var k := 1 to N do InterlockedIncrement(hit[k]);
  for i := 1 to N do
    if hit[i] <> 1 then halt(1);
end.
