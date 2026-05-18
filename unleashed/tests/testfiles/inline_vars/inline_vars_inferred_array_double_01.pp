program inline_vars_inferred_array_double_01;
{$mode unleashed}

// float literals -> array of Double regardless of literal precision

begin
  var a := [3.14, 2.71828, -1.5, 0.0, 1e10];
  if Length(a) <> 5 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Double) then halt(2);
  if Abs(a[0] - 3.14) > 1e-9 then halt(3);
  if Abs(a[1] - 2.71828) > 1e-9 then halt(4);
  if a[2] <> -1.5 then halt(5);
  if a[3] <> 0.0 then halt(6);
  if a[4] <> 1e10 then halt(7);
end.
