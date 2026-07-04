program parallelfor_chunk_edges_23;
{$mode unleashed}
uses SysUtils;
// chunk edge sizes: 1 (per-index), larger than the range, runtime value
// clamped up from 0
var n, zero: Integer;
begin
  n := 0;
  for parallel var i := 1 to 5000 chunk 1 do InterlockedIncrement(n);
  if n <> 5000 then halt(1);
  n := 0;
  for parallel var i := 1 to 10 chunk 512 do InterlockedIncrement(n);
  if n <> 10 then halt(2);
  zero := 0;
  n := 0;
  for parallel var i := 1 to 100 chunk zero do InterlockedIncrement(n);
  if n <> 100 then halt(3);
end.
