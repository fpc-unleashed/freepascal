program parallelfor_workerindex_seq_29;
{$mode unleashed}
// parallel(1): the caller is the only worker
begin
  for parallel(1) var i := 1 to 10 do
    if (WorkerIndex <> 0) or (WorkerCount <> 1) then halt(1);
end.
