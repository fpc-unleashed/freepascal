{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Double-precision autovectorizer: a[i]:=b[i] op c[i] over double dynamic arrays
  (op in + - *) fires the 128-bit SSE packed main loop (VL=2, movupd/addpd/
  subpd/mulpd) + scalar tail. Verified bit-exact against a scalar recompute
  (d:=b[i] op c[i], a non-matching shape that stays scalar) for every trip count
  0..17 and 100/1000, exercising both tail residues 0..1. }
program vect_double_add_sizes_01;
{$mode objfpc}{$H+}
function qb(x: double): qword; var q: qword absolute x; begin qb:=q; end;
procedure work(n: longint);
var a,b,c: array of double; i: longint; d: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
  for i:=0 to n-1 do begin d:=b[i]+c[i]; if qb(a[i])<>qb(d) then Halt(1); end;
  for i:=0 to n-1 do a[i]:=b[i]-c[i];
  for i:=0 to n-1 do begin d:=b[i]-c[i]; if qb(a[i])<>qb(d) then Halt(2); end;
  for i:=0 to n-1 do a[i]:=b[i]*c[i];
  for i:=0 to n-1 do begin d:=b[i]*c[i]; if qb(a[i])<>qb(d) then Halt(3); end;
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100); work(1000);
end.
