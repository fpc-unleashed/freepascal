{ %FAIL }
program asyncawait_await_nonfuture_fails_02;
{$mode unleashed}
var x: Integer;
begin
  x := 5;
  if await x = 5 then halt(0);
end.
