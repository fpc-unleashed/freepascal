program inline_vars_inferred_array_int_promotion_01;
{$mode unleashed}

// integer literals in an inferred array literal promote to LongInt
// (Int64 on 64-bit, LongInt on 32-bit) regardless of the literal's
// natural fit width - small numbers don't downsize the element type

begin
  var a := [1, 2, 3];
  if Length(a) <> 3 then halt(1);
  if SizeOf(a[0]) <> SizeOf(LongInt) then halt(2);
  if a[0] <> 1 then halt(3);
  if a[1] <> 2 then halt(4);
  if a[2] <> 3 then halt(5);

  // even if all literals fit in Byte, element type stays LongInt
  var b := [10, 200, 100];
  if Length(b) <> 3 then halt(6);
  if SizeOf(b[0]) <> SizeOf(LongInt) then halt(7);
end.
