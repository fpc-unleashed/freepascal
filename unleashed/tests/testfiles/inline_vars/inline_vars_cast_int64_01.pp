program inline_vars_cast_int64_01;
{$mode unleashed}

// explicit Int64 cast gives a guaranteed 8-byte signed slot; without the
// cast the literal `10` would have promoted to LongInt (4 bytes)

begin
  var i := Int64(10);
  if SizeOf(i) <> 8 then halt(1);
  if i <> 10 then halt(2);
end.
