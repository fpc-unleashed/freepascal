program parallelfor_chunk_break_25;
{$mode unleashed}
uses SysUtils;
// the cancel flag is checked inside the chunk walk: a single-worker break
// stops mid-chunk, not at the chunk boundary
var n: Integer;
begin
  n := 0;
  for parallel(1) var i := 1 to 100 chunk 8 do
  begin
    InterlockedIncrement(n);
    if i = 5 then break;
  end;
  if n <> 5 then halt(1);
end.
