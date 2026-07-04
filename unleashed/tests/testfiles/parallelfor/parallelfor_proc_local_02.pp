program parallelfor_proc_local_02;
{$mode unleashed}
uses SysUtils;
// the body reaches an enclosing-routine local across the worker threads
function Count(n: Integer): Integer;
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to n do InterlockedIncrement(s);
  Count := s;
end;
begin
  if Count(5000) <> 5000 then halt(1);
  if Count(1) <> 1 then halt(2);
  if Count(0) <> 0 then halt(3);
end.
