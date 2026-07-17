program int128_native_regpair_ops_01;

{ carry chains, compare jump sequences and in-place safety of the
  register-pair operations; globals force memory operands }

{$mode unleashed}

var
  ga, gb, gr: Int128;
  x, y, s, keep: Int128;
  u1: UInt128;
  k: longint;

begin
  { carry out of the low half }
  x := 18446744073709551615;                        { 2^64-1, hi = 0 }
  y := x + 1;                                       { 2^64, carry into hi }
  if y <> 18446744073709551616 then halt(1);
  if y - 1 <> x then halt(2);                       { borrow back }

  { high halves equal, the unsigned low compare decides }
  x := 110680464442257309695;                       { 5*2^64 + (2^64-1) }
  y := 110680464442257309696;                       { 6*2^64, x+1 }
  if not (x < y) then halt(3);
  if x >= y then halt(4);
  if y <= x then halt(5);

  { signed compares look at the high half }
  x := -1;
  if not (x < 0) then halt(6);
  u1 := high(UInt128);                              { same payload as -1 }
  if not (u1 > 0) then halt(7);

  { memory operand folded into the pair op }
  ga := 100000000000000000000;
  x := 23456789012345678901;
  s := x + ga;
  if s <> 123456789012345678901 then halt(8);

  { swapped subtraction: memory minus register }
  gb := 200000000000000000000;
  s := gb - (x + x);
  if s <> 153086421975308642198 then halt(9);

  { pair ops must not clobber their source }
  keep := 100000000000000000000;
  s := keep + 1;
  if keep <> 100000000000000000000 then halt(10);
  s := -keep;
  if keep <> 100000000000000000000 then halt(11);
  s := not keep;
  if keep <> 100000000000000000000 then halt(12);

  { cross terms of the multiplication }
  x := 18446744073709551619;                        { 2^64+3 }
  y := 18446744073709551621;                        { 2^64+5 }
  gr := x * y;                                      { low 128 bits }
  if gr <> 147573952589676412943 then halt(13);

  { loop-carried accumulation, regvar candidate }
  s := 0;
  for k := 1 to 1000 do
    s := s + 1000000000000000000000;
  if s <> 1000000000000000000000000 then halt(14);
end.
