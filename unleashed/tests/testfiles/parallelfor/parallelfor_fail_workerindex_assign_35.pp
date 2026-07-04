{ %FAIL }
program parallelfor_fail_workerindex_assign_35;
{$mode unleashed}
// WorkerIndex is read-only in the body
begin
  for parallel var i := 1 to 10 do
    WorkerIndex := 1;
end.
