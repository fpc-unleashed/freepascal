{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfsse64" }
{ Reduction autovectorization: single-precision sum  s:=s+a[i]  and dot product
  s:=s+a[i]*b[i] are widened to a 4-lane packed accumulator (lane 0 seeded with
  the incoming s, lanes 1..3 zero), accumulated 4-wide, then horizontally summed
  after the loop, with a scalar tail for the residue.
  A partial-sum reduction reassociates the FP adds, so the transform only fires
  under fast-math -- but for exactly-representable inputs (multiples of 1/8, and
  |partial sum| well under 2^24) there is no rounding, so every grouping yields
  the identical single value.  The oracle is a DESCENDING (downto) loop, which
  neither the vectorizer nor -OoREASSOC touch, so it stays a strict sequential
  scalar reduction.  Checked for every trip count 0..40, a large size, and with
  a nonzero incoming accumulator. }
program vect_reduce_01;
{$mode objfpc}{$H+}
procedure work(n: longint; base: single);
var a,b: array of single; i: longint; s,ref: single;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125 - 0.5; b[i]:=(i mod 4)*0.25 + 0.25; end;

  { sum, zero and nonzero incoming accumulator }
  s:=base; for i:=0 to n-1 do s:=s+a[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i];
  if s<>ref then Halt(1);

  { dot product }
  s:=base; for i:=0 to n-1 do s:=s+a[i]*b[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(2);

  { commuted dot addend order:  s := a[i]*b[i] + s }
  s:=base; for i:=0 to n-1 do s:=a[i]*b[i]+s;
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(3);
end;
var k: longint;
begin
  for k:=0 to 40 do
    begin
      work(k, 0.0);
      work(k, 7.5);
      work(k, -3.25);
    end;
  work(4096, 0.0);
  work(4096, 12.5);
  work(1000, -100.0);
end.
