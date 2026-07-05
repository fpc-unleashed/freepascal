{ Done flips to true without an await once the worker finishes }
program asyncawait_control_done_poll_20;
{$mode unleashed}
uses SysUtils;
var gate: boolean;
function work: integer;
begin
  while not gate do Sleep(1);
  result := 7;
end;
begin
  gate := false;
  var h := async work;
  if h.Done then halt(1);
  if h.Cancelled then halt(2);
  gate := true;
  while not h.Done do Sleep(1);
  if await h <> 7 then halt(3);
end.
