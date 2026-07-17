{ %OPT=-O3 }
program int128_val_hex_bitpattern_fold_o3_01;

{ the compile time fold of Val on constant strings must agree with the
  runtime helpers on base specific bit patterns }

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
  Val('$ffffffffffffffffffffffffffffffff', a, c);
  if (a <> -1) or (c <> 0) then halt(1);
  checks('$ffffffffffffffffffffffffffffffff', a, c, 2);
  Val('$80000000000000000000000000000000', a, c);
  if (a <> low(Int128)) or (c <> 0) then halt(3);
  checks('$80000000000000000000000000000000', a, c, 4);
  Val('-$ffffffffffffffffffffffffffffffff', a, c);
  if c = 0 then halt(5);
  checks('-$ffffffffffffffffffffffffffffffff', a, c, 6);
  Val('%11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111', a, c);
  if (a <> -1) or (c <> 0) then halt(7);
  checks('%11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111', a, c, 8);
  Val('&3777777777777777777777777777777777777777777', a, c);
  if (a <> -1) or (c <> 0) then halt(9);
  checks('&3777777777777777777777777777777777777777777', a, c, 10);
  Val('$ffffffffffffffffffffffffffffffff', u, c);
  if (u <> high(UInt128)) or (c <> 0) then halt(11);
  checku('$ffffffffffffffffffffffffffffffff', u, c, 12);
end.
