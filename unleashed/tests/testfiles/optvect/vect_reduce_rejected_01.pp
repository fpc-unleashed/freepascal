{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfsse64 -vn" }
{ Shapes the reduction vectorizer must decline (each falls back to correct scalar
  code and emits a cg_n_loop_not_vectorized note naming the reason):
    * a DOUBLE-precision accumulator (out of scope; only single is widened),
    * a two-statement loop body (would need two accumulators in lockstep),
    * an ADDRESS-TAKEN accumulator (@s makes it not provably a private local).
  The transform is measure-only, so every loop must still compute the same value
  as a strict sequential (downto) reference. }
program vect_reduce_rejected_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var
  a,b: array of single;
  da: array of double;
  i: longint;
  s,t,ref,reft: single;
  ds,dref: double;
  ps: ^single;
begin
  SetLength(a,n); SetLength(b,n); SetLength(da,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125-0.5; b[i]:=(i mod 4)*0.25+0.25; da[i]:=(i mod 8)*0.125-0.5; end;

  { rejected: double accumulator }
  ds:=0; for i:=0 to n-1 do ds:=ds+da[i];
  dref:=0; for i:=n-1 downto 0 do dref:=dref+da[i];
  if ds<>dref then Halt(1);

  { rejected: two statements in the body }
  s:=0; t:=0; for i:=0 to n-1 do begin s:=s+a[i]; t:=t+b[i]; end;
  ref:=0; reft:=0; for i:=n-1 downto 0 do begin ref:=ref+a[i]; reft:=reft+b[i]; end;
  if (s<>ref) or (t<>reft) then Halt(2);

  { rejected: address-taken accumulator }
  ps:=@s;
  s:=0; for i:=0 to n-1 do s:=s+a[i];
  ref:=0; for i:=n-1 downto 0 do ref:=ref+a[i];
  if (s<>ref) or (ps^<>ref) then Halt(3);
end;
var k: longint;
begin
  for k:=0 to 20 do work(k);
  work(517);
end.
