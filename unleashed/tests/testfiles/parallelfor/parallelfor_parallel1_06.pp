program parallelfor_parallel1_06;
{$mode unleashed}
uses SysUtils;
// parallel(1) runs on the calling thread alone, still correct
var s: Integer;
begin
  s := 0;
  for parallel(1) var i := 1 to 3000 do InterlockedIncrement(s);
  if s <> 3000 then halt(1);
end.
