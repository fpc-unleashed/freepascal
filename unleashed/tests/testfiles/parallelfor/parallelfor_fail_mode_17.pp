{ %FAIL }
program parallelfor_fail_mode_17;
{$mode objfpc}
// without the parallelfor modeswitch `parallel` is just an identifier and the
// header does not parse
begin
  for parallel var i := 1 to 5 do
    if i < 0 then halt(1);
end.
