{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Double-precision scalar-broadcast element-wise shapes:  a[i]:=b[i] op s ,
  a[i]:=s op b[i]  and a constant-literal operand. The invariant double scalar s
  is splatted ONCE before the vector loop (movsd + unpcklpd -> [s,s]); each lane
  then applies the identical op in the identical order, so the packed result is
  bit-exact against a scalar recompute for every tail residue (trip counts
  0..17, 100, 1000). Non-commutative s-b[i] must compute s-b per lane. }
program vect_double_scalar_broadcast_01;
{$mode objfpc}{$H+}
function qb(x: double): qword; var q: qword absolute x; begin qb:=q; end;
procedure work(n: longint; s: double);
var a,b: array of double; i: longint; d: double;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do b[i]:=i*1.5-3.25;

  for i:=0 to n-1 do a[i]:=b[i]+s;             { b[i] + s }
  for i:=0 to n-1 do begin d:=b[i]+s; if qb(a[i])<>qb(d) then Halt(1); end;

  for i:=0 to n-1 do a[i]:=s+b[i];             { s + b[i] (commutative) }
  for i:=0 to n-1 do begin d:=s+b[i]; if qb(a[i])<>qb(d) then Halt(2); end;

  for i:=0 to n-1 do a[i]:=b[i]*s;             { b[i] * s }
  for i:=0 to n-1 do begin d:=b[i]*s; if qb(a[i])<>qb(d) then Halt(3); end;

  for i:=0 to n-1 do a[i]:=b[i]-s;             { b[i] - s }
  for i:=0 to n-1 do begin d:=b[i]-s; if qb(a[i])<>qb(d) then Halt(4); end;

  for i:=0 to n-1 do a[i]:=s-b[i];             { s - b[i]  (NON-commutative) }
  for i:=0 to n-1 do begin d:=s-b[i]; if qb(a[i])<>qb(d) then Halt(5); end;

  for i:=0 to n-1 do a[i]:=b[i]*2.5;           { constant literal operand }
  for i:=0 to n-1 do begin d:=b[i]*2.5; if qb(a[i])<>qb(d) then Halt(6); end;

  for i:=0 to n-1 do a[i]:=0.75-b[i];          { constant literal, non-commutative }
  for i:=0 to n-1 do begin d:=0.75-b[i]; if qb(a[i])<>qb(d) then Halt(7); end;
end;
var k: longint;
begin
  for k:=0 to 17 do work(k, 3.25);
  work(100, -1.5);
  work(1000, 42.0);
  work(1000, 0.0);
end.
