program parallelfor_chunk_step_downto_24;
{$mode unleashed}
uses SysUtils;
// chunk composes with downto and step
var n: Integer;
begin
  n := 0;
  for parallel var i := 100 downto 1 step 2 chunk 7 do InterlockedIncrement(n);
  if n <> 50 then halt(1);
end.
