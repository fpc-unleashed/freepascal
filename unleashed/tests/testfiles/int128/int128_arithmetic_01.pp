program int128_arithmetic_01;

{ add/sub/mul/neg on values past 64 bit, with two's complement wraparound }

{$mode unleashed}

var
  a, b, c: Int128;
  u, v: UInt128;

begin
  a := 10000000000000000000;
  b := 10000000000000000000;
  c := a * b;
  if c <> 100000000000000000000000000000000000000 then halt(1);
  if c + 1 <> 100000000000000000000000000000000000001 then halt(2);
  if c - 2 <> 99999999999999999999999999999999999998 then halt(3);

  a := high(Int128);
  if a + 1 <> low(Int128) then halt(4);            { wraps }
  b := low(Int128);
  if b - 1 <> high(Int128) then halt(5);           { wraps }

  a := -123456789012345678901234567890;
  if -a <> 123456789012345678901234567890 then halt(6);
  if -(-a) <> a then halt(7);

  u := high(UInt128);
  if u + 1 <> 0 then halt(8);                       { wraps }
  v := 0;
  if v - 1 <> high(UInt128) then halt(9);           { wraps }

  a := 9223372036854775807;
  a := a * a;
  if a <> 85070591730234615847396907784232501249 then halt(10);
end.
