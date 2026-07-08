{ %OPT="-O3" }
{ Signed `mod` by a general (non-power-of-two) constant is lowered to the
  magic-number quotient (imul + shifts) followed by  left - q*c , avoiding a
  hardware idiv (nx86mat.pas). This test proves bit-exactness against the
  hardware/reference semantics across the tricky cases: negative dividends
  (Pascal mod truncates toward zero -> result takes the sign of the dividend),
  Low(LongInt)/Low(Int64), positive and negative divisors c and -c, and both
  longint and int64 widths. For each x it compares the constant-folded path
  against `x mod v` where v is an opaque variable holding the same constant
  (which forces a real idiv), so a mismatch means a miscompile.

  Special case: Low(Int64) mod -1 traps the hardware idiv (#DE overflow) even
  though the value is mathematically 0; the optimized/pow2 path must NOT trap
  and must yield 0, so that pair is checked directly rather than via idiv. }
program modconst_signed_01;
{$mode objfpc}

var
  vol: int64; { opaque; assigning through it forces a real idiv at the use site }

procedure chk32(x, c: longint);
var a, b: longint;
begin
  vol := c;
  case c of
    3:       a := x mod 3;
    7:       a := x mod 7;
    10:      a := x mod 10;
    -10:     a := x mod -10;
    1000003: a := x mod 1000003;
  else
    a := 0;
  end;
  b := x mod longint(vol);
  if a <> b then
    begin writeln('FAIL32 x=', x, ' c=', c, ' got=', a, ' want=', b); Halt(1); end;
end;

procedure chk64(x, c: int64);
var a, b: int64;
begin
  vol := c;
  case c of
    3:       a := x mod 3;
    7:       a := x mod 7;
    10:      a := x mod 10;
    -7:      a := x mod -7;
    1000003: a := x mod 1000003;
    -1:      a := x mod -1;
    9223372036854775807: a := x mod 9223372036854775807;
  else
    a := 0;
  end;
  if c = -1 then
    b := 0            { hardware idiv would trap on Low(Int64) mod -1 }
  else
    b := x mod vol;
  if a <> b then
    begin writeln('FAIL64 x=', x, ' c=', c, ' got=', a, ' want=', b); Halt(1); end;
end;

var
  cs32: array[0..4] of longint = (3, 7, 10, -10, 1000003);
  cs64: array[0..6] of int64   = (3, 7, 10, -7, 1000003, -1, 9223372036854775807);
  i: longint;
  x: int64;
begin
  for i := 0 to 4 do
    begin
      for x := -1000 to 1000 do chk32(x, cs32[i]);
      chk32(low(longint), cs32[i]);
      chk32(high(longint), cs32[i]);
      chk32(low(longint) + 1, cs32[i]);
      chk32(high(longint) - 1, cs32[i]);
    end;
  for i := 0 to 6 do
    begin
      for x := -1000 to 1000 do chk64(x, cs64[i]);
      chk64(low(int64), cs64[i]);
      chk64(high(int64), cs64[i]);
      chk64(low(int64) + 1, cs64[i]);
      chk64(high(int64) - 1, cs64[i]);
      chk64(-1234567890123, cs64[i]);
      chk64(1234567890123, cs64[i]);
    end;
  writeln('modconst_signed_01 ok');
  Halt(0);
end.
