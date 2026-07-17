program int128_divmod_limbs_01;

{ the 64 bit divisor path of the division runs schoolbook on 32 bit
  limbs; cover the single limb divisor, the normalized two limb divisor,
  the top bit set divisor and the full 128 bit fallback, then cross
  check q*n + r = z over a pseudo random sweep }

{$mode unleashed}

var
  u, q, r, n, seed: UInt128;
  a, sq, sr, sn: Int128;
  i: integer;

procedure next;
begin
  seed := seed * 6364136223846793005 + 1442695040888963407;
end;

begin
  { fixed vectors with exact expected results }
  u := high(UInt128);
  q := u div 10000000000000000000;
  r := u mod 10000000000000000000;
  if q <> 34028236692093846346 then halt(1);
  if r <> 3374607431768211455 then halt(2);

  u := UInt128(1) shl 64;
  if u div $100000000 <> $100000000 then halt(3);
  if u mod $100000000 <> 0 then halt(4);
  if u div $ffffffff <> 4294967297 then halt(5);
  if u mod $ffffffff <> 1 then halt(6);

  { divisor with the top bit already set, no normalize shift; the qword
    cast keeps the hex literal positive instead of sign extending }
  u := high(UInt128);
  q := u div UInt128(qword($8000000000000000));
  r := u mod UInt128(qword($8000000000000000));
  if q <> 36893488147419103231 then halt(7);
  if r <> 9223372036854775807 then halt(8);

  { pseudo random sweep, identity and remainder bound checked }
  seed := 88172645463325252;
  for i := 1 to 400 do
  begin
    next;
    u := seed;
    { single limb divisor }
    n := (seed shr 96) or 1;
    q := u div n;
    r := u mod n;
    if q * n + r <> u then halt(9);
    if r >= n then halt(10);
    { two limb divisor }
    n := (seed and high(qword)) or $100000000;
    q := u div n;
    r := u mod n;
    if q * n + r <> u then halt(11);
    if r >= n then halt(12);
    { wide divisor takes the 128 bit fallback }
    n := (seed shr 5) or 1;
    q := u div n;
    r := u mod n;
    if q * n + r <> u then halt(13);
    if r >= n then halt(14);
    { signed identity with both divisor signs }
    a := Int128(seed);
    sn := Int128(seed shr 68) + 2;
    sq := a div sn;
    sr := a mod sn;
    if sq * sn + sr <> a then halt(15);
    sq := a div -sn;
    sr := a mod -sn;
    if sq * -sn + sr <> a then halt(16);
  end;
end.
