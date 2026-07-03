program multi_var_init_double_01;

{$mode unleashed}

// 3.5 is exact in binary, so the compares stay precision-safe on i386
// where the literal is evaluated as 80-bit Extended
var
  x, y, z: Double = 3.5;

begin
  if x <> 3.5 then halt(1);
  if y <> 3.5 then halt(2);
  if z <> 3.5 then halt(3);
  x := 0;
  if y <> 3.5 then halt(4);
  if z <> 3.5 then halt(5);
end.
