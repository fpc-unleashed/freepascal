{ %OPT=-O4 }
{ Plain -O4 (no explicit -Oo switches): cs_opt_ifconvert is in the generic
  level-4 set, so a ReLU activation loop is widened by default. Result must match
  a scalar recompute across all tail residues. }
program ifconv_o4_default_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,ra: array of single; i: longint;
begin
  SetLength(a,n); SetLength(ra,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 9)-4.0; ra[i]:=a[i]; end;
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;
  for i:=0 to n-1 do
    begin if ra[i]<0 then ra[i]:=0; if a[i]<>ra[i] then Halt(1); end;
end;
var k: longint;
begin
  for k:=0 to 16 do work(k);
  work(513);
end.
