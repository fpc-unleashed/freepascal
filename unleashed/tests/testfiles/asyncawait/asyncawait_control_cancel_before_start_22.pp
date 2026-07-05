{ a cancel issued right after the spawn terminates the loop }
program asyncawait_control_cancel_before_start_22;
{$mode unleashed}
uses SysUtils;
begin
  var h := async begin
    while not Cancelled do Sleep(1);
  end;
  h.Cancel;
  await h;
  if not h.Cancelled then halt(1);
  if not h.Done then halt(2);
end.
