program for_counter_int32_arith_inference_01;

{$mode unleashed}
{$R-}
{$Q-}

var
  a: DWord = $FFFFFFFF;
  b: DWord = 1;
  count: LongInt = 0;
begin
  // counter inferred from wrapped 32-bit arithmetic stays 4 bytes,
  // so the loop starts at 0 on every target
  for var i := a + b to 2 do
  begin
    if SizeOf(i) <> 4 then halt(1);
    inc(count);
  end;
  if count <> 3 then halt(2);
end.
