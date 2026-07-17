{ %CPU=x86_64,aarch64 }
program parallelfor_int64_range_30;
{$mode unleashed}
uses SysUtils;
// values beyond 2^31 and a step pushing idx*step past 32 bits
var n: Integer;
begin
  n := 0;
  for parallel var i: Int64 := 4000000000 to 4000000999 do
  begin
    if (i < 4000000000) or (i > 4000000999) then halt(1);
    InterlockedIncrement(n);
  end;
  if n <> 1000 then halt(2);
  n := 0;
  for parallel var i: Int64 := 0 to 5000000000000 step 1000000000 do
    InterlockedIncrement(n);
  if n <> 5001 then halt(3);
end.
