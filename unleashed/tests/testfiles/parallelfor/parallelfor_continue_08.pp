program parallelfor_continue_08;
{$mode unleashed}
uses SysUtils;
// continue is allowed inside the body and skips to the next iteration
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to 100 do
  begin
    if (i mod 2) = 0 then continue;
    InterlockedIncrement(s);
  end;
  if s <> 50 then halt(1);
end.
