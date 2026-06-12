program parallelfor_threadcount_05;
{$mode unleashed}
uses SysUtils;
// an explicit pool size still covers every iteration exactly once
var s: Integer;
begin
  s := 0;
  for parallel(4) var i := 1 to 8000 do InterlockedIncrement(s);
  if s <> 8000 then halt(1);
end.
