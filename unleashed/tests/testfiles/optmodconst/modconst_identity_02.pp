{ %OPT="-O3" }
{ Cross-check of the signed constant `mod`/`div` magic lowerings: the division
  identity  (x div c)*c + (x mod c) = x  must hold exactly for every x, and the
  remainder must have the sign of the dividend (Pascal truncates toward zero).
  Divisors span small primes, ten, a large prime and their negatives, in both
  longint and int64 widths, including the range extremes. All operands are
  compile-time constants so the optimized (idiv-free) path is exercised. }
program modconst_identity_02;
{$mode objfpc}

procedure v32(x: longint); inline;

  procedure one(x, c, q, r: longint);
  begin
    if q * c + r <> x then
      begin writeln('IDFAIL32 x=', x, ' c=', c); Halt(1); end;
    if (r <> 0) and ((r < 0) <> (x < 0)) then
      begin writeln('SIGNFAIL32 x=', x, ' c=', c, ' r=', r); Halt(2); end;
  end;

begin
  one(x, 3,       x div 3,       x mod 3);
  one(x, 7,       x div 7,       x mod 7);
  one(x, 10,      x div 10,      x mod 10);
  one(x, -10,     x div -10,     x mod -10);
  one(x, 1000003, x div 1000003, x mod 1000003);
end;

procedure v64(x: int64); inline;

  procedure one(x, c, q, r: int64);
  begin
    if q * c + r <> x then
      begin writeln('IDFAIL64 x=', x, ' c=', c); Halt(3); end;
    if (r <> 0) and ((r < 0) <> (x < 0)) then
      begin writeln('SIGNFAIL64 x=', x, ' c=', c, ' r=', r); Halt(4); end;
  end;

begin
  one(x, 3,       x div 3,       x mod 3);
  one(x, 7,       x div 7,       x mod 7);
  one(x, -7,      x div -7,      x mod -7);
  one(x, 10,      x div 10,      x mod 10);
  one(x, 1000003, x div 1000003, x mod 1000003);
end;

var
  x: int64;
begin
  for x := -2000 to 2000 do
    begin
      v32(longint(x));
      v64(x);
    end;
  v32(low(longint)); v32(high(longint)); v32(low(longint) + 1);
  v64(low(int64) + 1); v64(high(int64)); v64(1234567890123); v64(-1234567890123);
  writeln('modconst_identity_02 ok');
  Halt(0);
end.
