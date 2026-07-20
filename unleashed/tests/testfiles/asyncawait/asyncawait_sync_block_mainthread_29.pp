{ a sync block on the main thread runs in place and captures by reference }
program asyncawait_sync_block_mainthread_29;
{$mode unleashed}
uses SysUtils, Classes;
var
  counter: Integer;
  tid: TThreadID;
begin
  counter := 1;
  sync begin
    counter := counter + 1;
    tid := GetCurrentThreadID;
  end;
  if counter <> 2 then halt(1);
  if tid <> GetCurrentThreadID then halt(2);
end.
