{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Autovectorizer: a[i]:=b[i]+c[i] over single dynamic arrays fires the 128-bit
  SSE packed main loop + scalar tail. Verified bit-exact against a scalar
  recompute (d:=b[i]+c[i], a non-matching shape that stays scalar) for every
  trip count 0..17 and 100/1000, exercising all tail residues 0..3. }
program vect_add_sizes_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c: array of single; i: longint; d: single;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
  for i:=0 to n-1 do begin d:=b[i]+c[i]; if a[i]<>d then Halt(1); end;
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100); work(1000);
end.
