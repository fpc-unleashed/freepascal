program inline_vars_int32_all_ops_inference_01;

{$mode unleashed}
{$R-}
{$Q-}

var
  a: LongWord = $C0000000;
  b: LongWord = 3;
begin
  // 32-bit arithmetic stays 32-bit on every target across all operators
  var s1 := a + b;
  if SizeOf(s1) <> 4 then halt(1);

  var s2 := a - b;
  if SizeOf(s2) <> 4 then halt(2);
  if s2 <> $BFFFFFFD then halt(3);

  var s3 := a * b;
  if SizeOf(s3) <> 4 then halt(4);

  var s4 := a div b;
  if SizeOf(s4) <> 4 then halt(5);
  if s4 <> $40000000 then halt(6);

  var s5 := a shl 2;
  if SizeOf(s5) <> 4 then halt(7);

  var s6 := a shr 2;
  if SizeOf(s6) <> 4 then halt(8);
  if s6 <> $30000000 then halt(9);
end.
