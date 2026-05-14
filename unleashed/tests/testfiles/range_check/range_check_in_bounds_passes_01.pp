{ %OPT=-Cr }
program range_check_in_bounds_passes_01;

{$mode unleashed}

var
  arr: array[0..4] of Integer;

begin
  for var i := 0 to 4 do
    arr[i] := i * 10;
  if arr[0] <> 0  then halt(1);
  if arr[4] <> 40 then halt(2);
end.
