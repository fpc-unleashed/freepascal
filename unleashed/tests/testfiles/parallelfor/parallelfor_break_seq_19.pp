program parallelfor_break_seq_19;
{$mode unleashed}
uses SysUtils;
// with one worker the cancel is deterministic: exactly the iterations up to
// the break run
var n: Integer;
begin
  n := 0;
  for parallel(1) var i := 1 to 100 do
  begin
    InterlockedIncrement(n);
    if i = 5 then break;
  end;
  if n <> 5 then halt(1);
end.
