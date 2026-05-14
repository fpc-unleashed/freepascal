program for_counter_break_01;

{$mode unleashed}

var
  i: Integer;
  arr: array[1..5] of Integer = (10, 20, 30, 40, 50);

begin
  for i := 1 to 5 do
    if arr[i] = 30 then break;
  // counter holds value at break time
  if i <> 3 then halt(1);
end.
