program parallelfor_break_cancels_20;
{$mode unleashed}
uses SysUtils;
// break raises the shared flag: no worker claims another iteration, so only
// a tiny fraction of a huge range runs and the loop still terminates
var n: Integer;
begin
  n := 0;
  for parallel var i := 1 to 100000000 do
  begin
    InterlockedIncrement(n);
    break;
  end;
  if (n < 1) or (n > 10000000) then halt(1);
end.
