{ %FAIL }
{ Cancelled inside the block is constref and cannot be assigned }
program asyncawait_control_assign_cancelled_fails_09;
{$mode unleashed}
uses SysUtils;
begin
  var h := async begin
    Cancelled := true;
  end;
  await h;
end.
