program parallelfor_workerindex_28;
{$mode unleashed}
uses SysUtils;
// WorkerIndex is 0..WorkerCount-1 and stable per worker; per-worker slots
// accumulate without atomics and the barrier makes the sum visible
var acc: array[0..3] of Int64; k: Integer; sum: Int64;
begin
  for k := 0 to 3 do acc[k] := 0;
  for parallel(4) var i := 1 to 100000 do
  begin
    if (WorkerIndex < 0) or (WorkerIndex >= WorkerCount) then halt(1);
    if WorkerCount <> 4 then halt(2);
    acc[WorkerIndex] := acc[WorkerIndex] + i;
  end;
  sum := 0;
  for k := 0 to 3 do sum := sum + acc[k];
  if sum <> 5000050000 then halt(3);
end.
