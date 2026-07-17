program int128_compare_convert_01;

{ signed vs unsigned ordering, widening from int64/qword, Str/Val roundtrip }

{$mode unleashed}

var
  a, b, c: Int128;
  u: UInt128;
  i: Int64;
  q: QWord;
  s: string;
  code: Integer;

begin
  { the same bit pattern orders differently under the two types }
  a := -1;
  u := high(UInt128);
  if not (a < 0) then halt(1);
  if not (u > 0) then halt(2);
  a := 170141183460469231731687303715884105727;
  b := -170141183460469231731687303715884105728;
  if not (a > b) then halt(3);
  if not (b < a) then halt(4);
  if not (a >= a) then halt(5);
  if a <> a then halt(6);

  { widening }
  i := high(Int64);
  a := i;
  if a <> 9223372036854775807 then halt(7);
  a := a + a;
  if a <> 18446744073709551614 then halt(8);
  i := -5;
  a := i;
  if a <> -5 then halt(9);
  q := high(QWord);
  u := q;
  if u <> 18446744073709551615 then halt(10);

  { Str / Val }
  c := 123456789012345678901234567890;
  Str(c, s);
  if s <> '123456789012345678901234567890' then halt(11);
  Val('-99999999999999999999999999999', c, code);
  if (code <> 0) or (c <> -99999999999999999999999999999) then halt(12);
  Val('12x', c, code);
  if code <> 3 then halt(13);
end.
