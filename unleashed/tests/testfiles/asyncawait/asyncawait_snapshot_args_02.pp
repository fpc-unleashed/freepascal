{ arguments are snapshotted at `async`, not read again on the worker }
program asyncawait_snapshot_args_02;
{$mode unleashed}
uses SysUtils;
function add(a, b: Integer): Integer;
begin
  Sleep(50);
  result := a + b;
end;
var a: Integer;
begin
  a := 2;
  var sum := async add(a, 3);
  a := 100;
  if await sum <> 5 then halt(1);
end.
