{ %OPT="-O4" }
{ The pass is part of the -O4 default switch set, so plain -O4 (no explicit
  -OoLOOPDISTPAT) enables it. Correctness must hold for fill and copy. }
program distpat_o4_default_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b: array of longint; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do b[i]:=i*3+1;
  for i:=0 to n-1 do a[i]:=0;
  for i:=0 to n-1 do if a[i]<>0 then Halt(1);
  for i:=0 to n-1 do a[i]:=b[i];
  for i:=0 to n-1 do if a[i]<>i*3+1 then Halt(2);
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(1000);
end.
