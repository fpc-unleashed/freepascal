{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Double-precision plain-copy shape  a[i]:=b[i]  lowers to a packed 16-byte
  movupd load+store main loop (VL=2) plus a scalar tail. Bit-exact against b for
  every tail residue (trip counts 0..17, 100, 1000). }
program vect_double_copy_01;
{$mode objfpc}{$H+}
function qb(x: double): qword; var q: qword absolute x; begin qb:=q; end;
procedure work(n: longint);
var a,b: array of double; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do b[i]:=i*0.5-7.0;
  for i:=0 to n-1 do a[i]:=b[i];
  for i:=0 to n-1 do if qb(a[i])<>qb(b[i]) then Halt(1);
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100);
  work(1000);
end.
