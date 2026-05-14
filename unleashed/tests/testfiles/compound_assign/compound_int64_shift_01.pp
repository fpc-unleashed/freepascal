program compound_int64_shift_01;

{$mode unleashed}

begin
  var n: Int64 := 1;
  n shl= 40;
  if n <> Int64(1) shl 40 then halt(1);

  n shr= 8;
  if n <> Int64(1) shl 32 then halt(2);
end.
