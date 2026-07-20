{ a sync block inside a worker runs on the main thread while the worker waits }
program asyncawait_sync_block_worker_30;
{$mode unleashed}
uses SysUtils, Classes;
var
  mainTid, ranOn: TThreadID;
  counter: Integer;
begin
  mainTid := GetCurrentThreadID;
  counter := 1;
  var f := async begin
    sync begin
      ranOn := GetCurrentThreadID;
      counter := counter + 10;
    end;
    { the worker resumes only after the main thread ran the block }
    counter := counter * 2;
  end;
  { pump the queue instead of await: await would deadlock against sync }
  while not f.Done do
    CheckSynchronize(10);
  CheckSynchronize(10);
  if ranOn <> mainTid then halt(1);
  if counter <> 22 then halt(2);
end.
