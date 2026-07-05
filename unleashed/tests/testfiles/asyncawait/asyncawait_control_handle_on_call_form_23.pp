{ the call-form handle carries the flag; the worker result is unaffected }
program asyncawait_control_handle_on_call_form_23;
{$mode unleashed}
uses SysUtils;
var gate: boolean;
function work(x: integer): integer;
begin
  while not gate do Sleep(1);
  result := x + 1;
end;
begin
  gate := false;
  var h := async work(41);
  h.Cancel;
  if not h.Cancelled then halt(1);
  gate := true;
  if await h <> 42 then halt(2);
  if not h.Done then halt(3);
end.
