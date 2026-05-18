program inline_vars_inferred_array_int_negative_01;
{$mode unleashed}

// LongInt is signed, so negative literals roundtrip cleanly

begin
  var a := [-1, -1000, 0, 42, -1_000_000];
  if Length(a) <> 5 then halt(1);
  if SizeOf(a[0]) <> SizeOf(LongInt) then halt(2);
  if a[0] <> -1 then halt(3);
  if a[1] <> -1000 then halt(4);
  if a[2] <> 0 then halt(5);
  if a[3] <> 42 then halt(6);
  if a[4] <> -1_000_000 then halt(7);
end.
