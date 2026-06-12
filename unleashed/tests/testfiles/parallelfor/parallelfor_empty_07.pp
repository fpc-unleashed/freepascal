program parallelfor_empty_07;
{$mode unleashed}
uses SysUtils;
// an empty range runs the body zero times
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to 0 do InterlockedIncrement(s);
  if s <> 0 then halt(1);
end.
