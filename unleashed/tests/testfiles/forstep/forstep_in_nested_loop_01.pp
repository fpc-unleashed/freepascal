program forstep_in_nested_loop_01;

{$mode unleashed}

begin
  var sum := 0;
  for var i := 1 to 10 step 2 do
    for var j := 1 to 10 step 3 do
      sum := sum + i + j;
  // i: 1,3,5,7,9 (5 values, sum=25)
  // j: 1,4,7,10 (4 values, sum=22)
  // total = 5 * 22 + 4 * 25 = 110 + 100 = 210
  if sum <> 210 then halt(1);
end.
