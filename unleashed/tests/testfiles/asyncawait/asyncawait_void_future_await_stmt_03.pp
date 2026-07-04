{ a bare `future` joined with `await` used as a statement }
program asyncawait_void_future_await_stmt_03;
{$mode unleashed}
uses SysUtils;
var done: Integer;
procedure work;
begin
  done := 7;
end;
begin
  done := 0;
  var w: future := async work;
  await w;
  if done <> 7 then halt(1);
end.
