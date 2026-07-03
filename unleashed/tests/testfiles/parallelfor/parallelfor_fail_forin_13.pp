{ %FAIL }
program parallelfor_fail_forin_13;
{$mode unleashed}
// `for parallel` cannot iterate a container; only a numeric range
var a: array[0..2] of Integer = (1, 2, 3);
begin
  for parallel var x in a do
    if x < 0 then halt(1);
end.
