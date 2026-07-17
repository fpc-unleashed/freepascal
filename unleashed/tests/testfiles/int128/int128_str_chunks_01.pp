program int128_str_chunks_01;

{ decimal conversion cuts the value into chunks of 10^19; cover the
  chunk boundaries and the zero padding of the lower chunks }

{$mode unleashed}

var
  s: shortstring;
  u: UInt128;
  a: Int128;
begin
  { single chunk, plain 64 bit path }
  u := 0;
  Str(u, s);
  if s <> '0' then halt(1);
  u := 9999999999999999999;
  Str(u, s);
  if s <> '9999999999999999999' then halt(2);

  { two chunks, lower chunk fully padded }
  u := 10000000000000000000;
  Str(u, s);
  if s <> '10000000000000000000' then halt(3);
  u := 10000000000000000001;
  Str(u, s);
  if s <> '10000000000000000001' then halt(4);
  u := UInt128(1) shl 64;
  Str(u, s);
  if s <> '18446744073709551616' then halt(5);

  { three chunks, middle and lower chunks padded }
  u := 100000000000000000000000000000000000000;
  Str(u, s);
  if s <> '100000000000000000000000000000000000000' then halt(6);
  u := u - 1;
  Str(u, s);
  if s <> '99999999999999999999999999999999999999' then halt(7);
  u := 100000000000000000000000000000000000005;
  Str(u, s);
  if s <> '100000000000000000000000000000000000005' then halt(8);
  u := high(UInt128);
  Str(u, s);
  if s <> '340282366920938463463374607431768211455' then halt(9);

  { signed carries the sign around the same core }
  a := high(Int128);
  Str(a, s);
  if s <> '170141183460469231731687303715884105727' then halt(10);
  a := low(Int128);
  Str(a, s);
  if s <> '-170141183460469231731687303715884105728' then halt(11);
  a := -1;
  Str(a, s);
  if s <> '-1' then halt(12);

  { width padding on top of the digits }
  u := high(UInt128);
  Str(u:45, s);
  if s <> '      340282366920938463463374607431768211455' then halt(13);
  a := -42;
  Str(a:5, s);
  if s <> '  -42' then halt(14);
end.
