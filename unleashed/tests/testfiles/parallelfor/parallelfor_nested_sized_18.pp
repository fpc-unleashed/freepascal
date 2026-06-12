program parallelfor_nested_sized_18;
{$mode unleashed}
uses SysUtils;
// an explicit inner pool size is kept inside an outer parallel loop (nested
// parallelism is opt-in); the dispatch still covers every (i,j) pair once
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to 8 do
    for parallel(4) var j := 1 to 500 do InterlockedIncrement(s);
  if s <> 4000 then halt(1);
end.
