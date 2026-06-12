program parallelfor_step_04;
{$mode unleashed}
uses SysUtils;
// step composes with the pool: 1,3,5,...,199 is 100 values
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to 200 step 2 do InterlockedIncrement(s);
  if s <> 100 then halt(1);
end.
