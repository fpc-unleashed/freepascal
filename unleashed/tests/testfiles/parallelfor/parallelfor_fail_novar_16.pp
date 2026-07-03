{ %FAIL }
program parallelfor_fail_novar_16;
{$mode unleashed}
// the loop variable must be declared inline so each worker owns its own copy
var i: Integer;
begin
  for parallel i := 1 to 5 do
    if i < 0 then halt(1);
end.
