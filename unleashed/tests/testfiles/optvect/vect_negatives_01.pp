{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Non-matching shapes must compile to correct code (the vectorizer must not
  miscompile): shifted read index a[i+1], integer arrays, and a downto loop stay
  scalar; a plain double-precision array now vectorizes (bit-exact) since the
  double extension landed. Each result is checked against an independent
  recompute, guarding both the must-not-fire boundary and double bit-exactness. }
program vect_negatives_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c: array of single; ai,bi,ci: array of longint;
    ad,bd,cd: array of double; i: longint;
begin
  SetLength(a,n);SetLength(b,n);SetLength(c,n);
  SetLength(ai,n);SetLength(bi,n);SetLength(ci,n);
  SetLength(ad,n);SetLength(bd,n);SetLength(cd,n);
  for i:=0 to n-1 do begin b[i]:=i*0.5;c[i]:=i;bi[i]:=i;ci[i]:=2*i;bd[i]:=i*0.5;cd[i]:=i; end;
  { shifted index: not the plain counter -> scalar }
  for i:=0 to n-2 do a[i]:=b[i+1]+c[i];
  for i:=0 to n-2 do if a[i]<>b[i+1]+c[i] then Halt(1);
  { integer arrays -> not single -> scalar }
  for i:=0 to n-1 do ai[i]:=bi[i]+ci[i];
  for i:=0 to n-1 do if ai[i]<>bi[i]+ci[i] then Halt(2);
  { double arrays -> now vectorized (bit-exact mulpd), result still matches }
  for i:=0 to n-1 do ad[i]:=bd[i]*cd[i];
  for i:=0 to n-1 do if ad[i]<>bd[i]*cd[i] then Halt(3);
  { downto -> not ascending -> scalar }
  for i:=n-1 downto 0 do a[i]:=b[i]-c[i];
  for i:=0 to n-1 do if a[i]<>b[i]-c[i] then Halt(4);
end;
var k: longint;
begin
  for k:=1 to 10 do work(k); work(64);
end.
