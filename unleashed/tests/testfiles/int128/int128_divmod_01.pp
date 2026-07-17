program int128_divmod_01;

{ signed and unsigned div/mod: truncation toward zero, mod sign follows the
  dividend }

{$mode unleashed}

var
  a, b: Int128;
  u, v: UInt128;

begin
  a := 100000000000000000000000000000000000000;
  b := 7;
  if a div b <> 14285714285714285714285714285714285714 then halt(1);
  if a mod b <> 2 then halt(2);

  a := -100;
  if a div 7 <> -14 then halt(3);
  if a mod 7 <> -2 then halt(4);
  a := 100;
  if a div -7 <> -14 then halt(5);
  if a mod -7 <> 2 then halt(6);
  a := -100;
  if a div -7 <> 14 then halt(7);
  if a mod -7 <> -2 then halt(8);

  u := 340282366920938463463374607431768211455;
  v := 1000000000;
  if u div v <> 340282366920938463463374607431 then halt(9);
  if u mod v <> 768211455 then halt(10);

  a := high(Int128);
  if a div -1 <> -170141183460469231731687303715884105727 then halt(11);
  b := low(Int128);
  if b div 1 <> low(Int128) then halt(12);
end.
