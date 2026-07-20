{ the one-statement form sync <stmt> works like a one-statement block }
program asyncawait_sync_single_stmt_33;
{$mode unleashed}
uses SysUtils, Classes;
var
  mainTid, ranOn: TThreadID;
  counter: Integer;
procedure bump(n: Integer);
begin
  counter := counter + n;
  ranOn := GetCurrentThreadID;
end;
begin
  mainTid := GetCurrentThreadID;
  counter := 1;
  { call statement }
  sync bump(1);
  if (counter <> 2) or (ranOn <> mainTid) then halt(1);
  { assignment statement }
  sync counter := counter + 1;
  if counter <> 3 then halt(2);
  { structured statement }
  sync if counter = 3 then counter := 7;
  if counter <> 7 then halt(3);
  { from a worker: runs on the main thread while the worker waits }
  var f := async begin
    sync bump(10);
    counter := counter * 2;
  end;
  while not f.Done do
    CheckSynchronize(10);
  CheckSynchronize(10);
  if (counter <> 34) or (ranOn <> mainTid) then halt(4);
end.
