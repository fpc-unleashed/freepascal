program int128_shifts_bitwise_01;

{ shl/shr over the full payload (shr is logical) and and/or/xor/not }

{$mode unleashed}

var
  u, v: UInt128;
  a: Int128;

begin
  u := 1;
  if u shl 127 <> 170141183460469231731687303715884105728 then halt(1);
  if (u shl 127) shr 127 <> 1 then halt(2);
  u := 1;
  if u shl 64 <> 18446744073709551616 then halt(3);
  if u shl 63 <> 9223372036854775808 then halt(4);

  { shr is logical even for a signed negative value }
  a := -1;
  if a shr 1 <> high(Int128) then halt(5);

  u := 18446744073709551615;         { low 64 bits set }
  v := u shl 64;                     { high 64 bits set }
  if (u or v) <> high(UInt128) then halt(6);
  if (u and v) <> 0 then halt(7);
  if (u xor u) <> 0 then halt(8);
  if (u xor high(UInt128)) <> v then halt(9);
  if not UInt128(0) <> high(UInt128) then halt(10);
  if not u <> v then halt(11);
end.
