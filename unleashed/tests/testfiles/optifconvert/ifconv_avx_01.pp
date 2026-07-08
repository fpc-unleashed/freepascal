{ %OPT="-O4 -Cfavx2" }
{ Under an AVX fputype the packed min/max activation uses the VEX v-forms
  (vmovups / vmaxps / vminps); every lane must stay bit-identical to the scalar
  if-converted maxss/minss. Covers ReLU, both one-sided clamps and an element-
  wise max, checked against a scalar recompute over all tail residues. }
program ifconv_avx_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,ra,b: array of single; i: longint; lo,hi,x: single;
begin
  SetLength(a,n); SetLength(ra,n); SetLength(b,n);
  lo:=-1.0; hi:=4.0;
  for i:=0 to n-1 do begin a[i]:=(i*3-11)*0.4; b[i]:=(i-5)*0.7; ra[i]:=a[i]; end;
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;
  for i:=0 to high(a) do if a[i]<lo then a[i]:=lo;
  for i:=0 to high(a) do if a[i]>hi then a[i]:=hi;
  for i:=0 to high(a) do if b[i]>a[i] then a[i]:=b[i];
  for i:=0 to n-1 do begin
    x:=ra[i];
    if x<0 then x:=0;
    if x<lo then x:=lo;
    if x>hi then x:=hi;
    if b[i]>x then x:=b[i];
    if a[i]<>x then Halt(1);
  end;
end;
var k: longint;
begin
  for k:=0 to 19 do work(k);
  work(257);
end.
