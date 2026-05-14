program compound_shift_01;

{$mode unleashed}

begin
  var n: LongWord := 1;
  n shl= 4;
  if n <> 16 then halt(1);

  n := 256;
  n shr= 2;
  if n <> 64 then halt(2);
end.
