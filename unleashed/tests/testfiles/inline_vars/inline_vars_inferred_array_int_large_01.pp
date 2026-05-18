program inline_vars_inferred_array_int_large_01;
{$mode unleashed}

// mix of small and large positive integers; the LongInt element type
// accommodates the full signed 32-bit range up to 2_147_483_647

begin
  var a := [1_000_000, 1_500_000_000, 2_147_483_647];
  if Length(a) <> 3 then halt(1);
  if SizeOf(a[0]) <> SizeOf(LongInt) then halt(2);
  if a[0] <> 1_000_000 then halt(3);
  if a[1] <> 1_500_000_000 then halt(4);
  if a[2] <> 2_147_483_647 then halt(5);
end.
