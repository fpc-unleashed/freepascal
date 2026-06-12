program parallelfor_downto_03;
{$mode unleashed}
uses SysUtils;
// downto runs the same set of values, just from the top
var s: Integer;
begin
  s := 0;
  for parallel var i := 100 downto 1 do InterlockedIncrement(s);
  if s <> 100 then halt(1);
end.
