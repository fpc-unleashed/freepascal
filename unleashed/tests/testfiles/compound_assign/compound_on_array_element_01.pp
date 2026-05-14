program compound_on_array_element_01;

{$mode unleashed}

var
  arr: array[0..2] of Integer = (10, 20, 30);

begin
  arr[0] += 5;
  if arr[0] <> 15 then halt(1);
  arr[1] -= 5;
  if arr[1] <> 15 then halt(2);
  arr[2] *= 2;
  if arr[2] <> 60 then halt(3);
end.
