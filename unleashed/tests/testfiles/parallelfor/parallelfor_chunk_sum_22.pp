{ %CPU=x86_64,aarch64 }
program parallelfor_chunk_sum_22;
{$mode unleashed}
uses SysUtils;
// an explicit chunk still covers every index exactly once
var s: Int64;
begin
  s := 0;
  for parallel var i := 1 to 100000 chunk 1000 do
    InterlockedExchangeAdd64(s, i);
  if s <> 5000050000 then halt(1);
end.
