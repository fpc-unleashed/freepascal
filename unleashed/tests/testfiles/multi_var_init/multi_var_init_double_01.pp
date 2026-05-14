program multi_var_init_double_01;

{$mode unleashed}

var
  x, y, z: Double = 3.14;

begin
  if x <> 3.14 then halt(1);
  if y <> 3.14 then halt(2);
  if z <> 3.14 then halt(3);
  x := 0;
  if y <> 3.14 then halt(4);
  if z <> 3.14 then halt(5);
end.
