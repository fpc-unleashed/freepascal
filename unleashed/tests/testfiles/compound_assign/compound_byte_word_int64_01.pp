program compound_byte_word_int64_01;

{$mode unleashed}

begin
  var b: Byte := 10;
  b += 20;
  if b <> 30 then halt(1);

  var w: Word := 1000;
  w *= 5;
  if w <> 5000 then halt(2);

  var q: Int64 := 1;
  q shl= 50;
  if q <> Int64(1) shl 50 then halt(3);
end.
