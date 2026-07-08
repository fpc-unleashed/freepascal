{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Autovectorizer for the * and - element-wise shapes. Bit-exact vs scalar
  recompute across tail residues. }
program vect_mul_sub_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c: array of single; i: longint; d: single;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=i*1.5-3; c[i]:=i*0.75+0.1; end;
  for i:=0 to n-1 do a[i]:=b[i]*c[i];
  for i:=0 to n-1 do begin d:=b[i]*c[i]; if a[i]<>d then Halt(1); end;
  for i:=0 to n-1 do a[i]:=b[i]-c[i];
  for i:=0 to n-1 do begin d:=b[i]-c[i]; if a[i]<>d then Halt(2); end;
end;
var k: longint;
begin
  for k:=0 to 12 do work(k);
  work(255);
end.
