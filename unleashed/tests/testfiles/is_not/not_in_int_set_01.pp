program not_in_int_set_01;

{$mode unleashed}

begin
  var n := 5;
  if n not in [1, 2, 3, 4] then else halt(1);
  if n not in [5, 6, 7]    then halt(2);

  n := 100;
  if n not in [1..50]      then else halt(3);
  if n not in [50..150]    then halt(4);
end.
