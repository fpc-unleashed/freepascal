{ %OPT=-O3 }
program int128_val_fold_o3_01;

{ at -O3 Val on a constant string folds at compile time; the uint128
  helper used to crash the fold (it has no data size parameter) and the
  int128 helper did not fold at all - compare folded results against the
  runtime path (a string variable defeats the fold) }

{$mode unleashed}

procedure checks(const lit: string; fv: Int128; fc: integer; id: integer);
var
  s: shortstring;
  rv: Int128;
  rc: integer;
begin
  s := lit;
  Val(s, rv, rc);
  if (rv <> fv) or (rc <> fc) then halt(id);
end;

procedure checku(const lit: string; fv: UInt128; fc: integer; id: integer);
var
  s: shortstring;
  rv: UInt128;
  rc: integer;
begin
  s := lit;
  Val(s, rv, rc);
  if (rv <> fv) or (rc <> fc) then halt(id);
end;

var
  a: Int128;
  u: UInt128;
  c: integer;
begin
  { decimal }
  Val('123', a, c);
  if (a <> 123) or (c <> 0) then halt(1);
  checks('123', a, c, 2);
  Val('-99', a, c);
  if (a <> -99) or (c <> 0) then halt(3);
  checks('-99', a, c, 4);
  { hex, octal, binary prefixes }
  Val('$ff', a, c);
  if (a <> 255) or (c <> 0) then halt(5);
  checks('$ff', a, c, 6);
  Val('0xff', a, c); checks('0xff', a, c, 7);
  Val('&777', a, c); checks('&777', a, c, 8);
  Val('%1010', a, c); checks('%1010', a, c, 9);
  Val('-$ff', a, c); checks('-$ff', a, c, 10);
  { full 128 bit range }
  Val('170141183460469231731687303715884105727', a, c);
  if (a <> high(Int128)) or (c <> 0) then halt(11);
  checks('170141183460469231731687303715884105727', a, c, 12);
  Val('-170141183460469231731687303715884105728', a, c);
  if (a <> low(Int128)) or (c <> 0) then halt(13);
  checks('-170141183460469231731687303715884105728', a, c, 14);
  { out of range and malformed inputs set nonzero codes }
  Val('170141183460469231731687303715884105728', a, c);
  if c = 0 then halt(15);
  checks('170141183460469231731687303715884105728', a, c, 16);
  Val('999999999999999999999999999999999999999999999', a, c);
  if c = 0 then halt(17);
  checks('999999999999999999999999999999999999999999999', a, c, 18);
  Val('12abc', a, c);
  if c <> 3 then halt(19);
  checks('12abc', a, c, 20);
  Val('', a, c);
  if c = 0 then halt(21);
  checks('', a, c, 22);

  { unsigned }
  Val('340282366920938463463374607431768211455', u, c);
  if (u <> high(UInt128)) or (c <> 0) then halt(23);
  checku('340282366920938463463374607431768211455', u, c, 24);
  Val('340282366920938463463374607431768211456', u, c);
  if c = 0 then halt(25);
  checku('340282366920938463463374607431768211456', u, c, 26);
  Val('$ffffffffffffffffffffffffffffffff', u, c);
  if (u <> high(UInt128)) or (c <> 0) then halt(27);
  checku('$ffffffffffffffffffffffffffffffff', u, c, 28);
  { a negative value does not fit an unsigned target, but -0 does }
  Val('-1', u, c);
  if c <> 1 then halt(29);
  checku('-1', u, c, 30);
  Val('-0', u, c);
  if (u <> 0) or (c <> 0) then halt(31);
  checku('-0', u, c, 32);
end.
