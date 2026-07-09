{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfsse64 -Oodeadstore" }
{ Regression: -Oodeadstore x -OoVECTORIZE reduction miscompile.

  The autovectorizer's reduction path seeds lane 0 of the packed accumulator
  with the incoming scalar accumulator  s  (the user's  s:=<start>  store just
  before the loop).  That seed read used to be embedded directly inside the
  create_reduce_init backend node, whose operand reads are not modelled by DFA;
  so with dead-store elimination enabled the  s:=<start>  def looked dead and
  was removed, seeding lane 0 from a stale stack slot -> wrong sum/dot result.

  This test forces BOTH -OoVECTORIZE and -Oodeadstore (independently of the
  suite-wide default) so it fails before the fix and passes after.  The inputs
  are exact multiples of 1/8 with |partial sum| well under 2^24 / 2^53, so the
  partial-sum reassociation the vectorizer performs is bit-exact against the
  strict sequential (downto) scalar oracle for every trip count.  Both single
  and double precision, sum and dot product, are exercised, with zero and
  nonzero incoming accumulators. }
program vect_reduce_deadstore_01;
{$mode objfpc}{$H+}

procedure work_single(n: longint; base: single);
var a,b: array of single; i: longint; s,ref: single;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125 - 0.5; b[i]:=(i mod 4)*0.25 + 0.25; end;
  s:=base; for i:=0 to n-1 do s:=s+a[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i];
  if s<>ref then Halt(1);
  s:=base; for i:=0 to n-1 do s:=s+a[i]*b[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(2);
end;

procedure work_double(n: longint; base: double);
var a,b: array of double; i: longint; s,ref: double;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125 - 0.5; b[i]:=(i mod 4)*0.25 + 0.25; end;
  s:=base; for i:=0 to n-1 do s:=s+a[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i];
  if s<>ref then Halt(3);
  s:=base; for i:=0 to n-1 do s:=s+a[i]*b[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(4);
end;

var k: longint;
begin
  for k:=0 to 40 do
    begin
      work_single(k, 0.0); work_single(k, 7.5); work_single(k, -3.25);
      work_double(k, 0.0); work_double(k, 7.5); work_double(k, -3.25);
    end;
  work_single(4096, 0.0); work_single(4096, 12.5); work_single(1000, -100.0);
  work_double(4096, 0.0); work_double(4096, 12.5); work_double(1000, -100.0);
end.
