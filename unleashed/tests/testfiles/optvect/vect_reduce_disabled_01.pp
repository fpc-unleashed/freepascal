{ %OPT="-O4 -Cfsse64" }
{ Disabled control: the autovectorizer is opt-in, so at -O4 WITHOUT -OoVECTORIZE
  the reduction stays scalar (only -OoREASSOC may split it into partial scalar
  accumulators).  The sum and dot product must still be correct against a strict
  sequential (downto) reference.  Companion to vect_reduce_01. }
program vect_reduce_disabled_01;
{$mode objfpc}{$H+}
procedure work(n: longint; base: single);
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
var k: longint;
begin
  for k:=0 to 20 do begin work(k,0.0); work(k,5.0); end;
  work(1000,-2.5);
end.
