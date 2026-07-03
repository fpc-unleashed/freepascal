{ %FAIL }
program parallelfor_fail_workercount_inc_36;
{$mode unleashed}
// WorkerCount cannot be passed as a var parameter either
begin
  for parallel var i := 1 to 10 do
    Inc(WorkerCount);
end.
