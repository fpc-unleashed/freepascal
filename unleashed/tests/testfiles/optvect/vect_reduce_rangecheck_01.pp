{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cr -Cfsse64" }
{ With range checking (-Cr) the reduction vectorizer disables itself so the
  per-element bounds checks are preserved on the scalar path; the sum and dot
  product must still be correct. }
program vect_reduce_rangecheck_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b: array of single; i: longint; s,ref: single;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125-0.5; b[i]:=(i mod 4)*0.25+0.25; end;
  s:=0; for i:=0 to n-1 do s:=s+a[i];
  ref:=0; for i:=n-1 downto 0 do ref:=ref+a[i];
  if s<>ref then Halt(1);
  s:=0; for i:=0 to n-1 do s:=s+a[i]*b[i];
  ref:=0; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(2);
end;
var k: longint;
begin
  for k:=0 to 9 do work(k);
  work(300);
end.
