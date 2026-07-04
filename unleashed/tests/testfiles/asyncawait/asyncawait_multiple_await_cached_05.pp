{ multiple `await` on the same future return the cached result }
program asyncawait_multiple_await_cached_05;
{$mode unleashed}
uses SysUtils;
function add(a, b: Integer): Integer;
begin
  result := a + b;
end;
begin
  var sum := async add(2, 3);
  if await sum <> 5 then halt(1);
  if await sum <> 5 then halt(2);
  if await sum + 1 <> 6 then halt(3);
end.
