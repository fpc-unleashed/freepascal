{ %FAIL }
{ the control members are read-only: assigning to Done is an error }
program asyncawait_control_assign_done_fails_08;
{$mode unleashed}
uses SysUtils;
begin
  var h := async begin Sleep(1); end;
  h.Done := true;
end.
