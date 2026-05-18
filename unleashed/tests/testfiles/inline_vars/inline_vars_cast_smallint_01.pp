program inline_vars_cast_smallint_01;
{$mode unleashed}

// explicit SmallInt cast keeps the variable at 2 bytes (16-bit signed);
// without the cast `-5` would have promoted to LongInt

begin
  var s := SmallInt(-5);
  if SizeOf(s) <> SizeOf(SmallInt) then halt(1);
  if SizeOf(s) <> 2 then halt(2);
  if s <> -5 then halt(3);
end.
