program int128_val_hex_bitpattern_01;

{ Val on the signed 128 bit type accepts full bit patterns for the hex,
  octal and binary bases, mirroring the smaller signed types; decimal
  keeps rejecting values above high(Int128) }

{$mode unleashed}

var
  a: Int128;
  u: UInt128;
  i64: Int64;
  c: integer;
begin
  { the int64 reference behavior the 128 bit type mirrors }
  Val('$ffffffffffffffff', i64, c);
  if (i64 <> -1) or (c <> 0) then halt(1);

  { hex full patterns }
  Val('$ffffffffffffffffffffffffffffffff', a, c);
  if (a <> -1) or (c <> 0) then halt(2);
  Val('$80000000000000000000000000000000', a, c);
  if (a <> low(Int128)) or (c <> 0) then halt(3);
  Val('$7fffffffffffffffffffffffffffffff', a, c);
  if (a <> high(Int128)) or (c <> 0) then halt(4);

  { 0x and x prefixes take the same route }
  Val('0xffffffffffffffffffffffffffffffff', a, c);
  if (a <> -1) or (c <> 0) then halt(5);
  Val('xffffffffffffffffffffffffffffffff', a, c);
  if (a <> -1) or (c <> 0) then halt(6);

  { binary full pattern: 128 ones }
  Val('%11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111', a, c);
  if (a <> -1) or (c <> 0) then halt(7);

  { octal full pattern: 3 followed by 42 sevens }
  Val('&3777777777777777777777777777777777777777777', a, c);
  if (a <> -1) or (c <> 0) then halt(8);

  { a negative input is still bounded by the magnitude }
  Val('-$ff', a, c);
  if (a <> -255) or (c <> 0) then halt(9);
  Val('-$80000000000000000000000000000000', a, c);
  if (a <> low(Int128)) or (c <> 0) then halt(10);
  Val('-$ffffffffffffffffffffffffffffffff', a, c);
  if c = 0 then halt(11);

  { decimal above high(Int128) keeps failing }
  Val('170141183460469231731687303715884105728', a, c);
  if c = 0 then halt(12);

  { one hex digit too many overflows }
  Val('$1ffffffffffffffffffffffffffffffff', a, c);
  if c = 0 then halt(13);

  { the unsigned type is unchanged }
  Val('$ffffffffffffffffffffffffffffffff', u, c);
  if (u <> high(UInt128)) or (c <> 0) then halt(14);
  Val('%1111', u, c);
  if (u <> 15) or (c <> 0) then halt(15);
  Val('&777', u, c);
  if (u <> 511) or (c <> 0) then halt(16);
end.
