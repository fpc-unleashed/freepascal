program parallelfor_main_sum_01;
{$mode unleashed}
uses SysUtils;
// the worker pool covers every iteration once: a parallel sum of 1..N
// equals the sequential sum
var s, i, want: Integer;
begin
  s := 0;
  for parallel var k := 1 to 10000 do InterlockedExchangeAdd(s, k);
  want := 0;
  for i := 1 to 10000 do want := want + i;
  if s <> want then halt(1);
end.
