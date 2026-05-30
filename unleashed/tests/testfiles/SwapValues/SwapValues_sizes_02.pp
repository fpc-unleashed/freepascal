program SwapValues_sizes_02;
{$mode unleashed}
var
  b1, b2: Byte;
  w1, w2: Word;
  l1, l2: LongWord;
  q1, q2: QWord;
begin
  b1 := 1; b2 := 2; SwapValues(b1, b2);
  if (b1 <> 2) or (b2 <> 1) then halt(1);
  w1 := 1000; w2 := 2000; SwapValues(w1, w2);
  if (w1 <> 2000) or (w2 <> 1000) then halt(2);
  l1 := 100000; l2 := 200000; SwapValues(l1, l2);
  if (l1 <> 200000) or (l2 <> 100000) then halt(3);
  q1 := 10000000000; q2 := 20000000000; SwapValues(q1, q2);
  if (q1 <> 20000000000) or (q2 <> 10000000000) then halt(4);
end.
