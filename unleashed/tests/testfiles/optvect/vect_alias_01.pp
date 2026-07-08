{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Same-index element-wise ops are alias-safe even when a and b reference the
  same dynamic-array block (a:=b): the packed load of the window precedes the
  store, so a[i]:=a[i]+c[i] computes each lane from the old value exactly as the
  scalar loop would. Verified bit-exact against a scalar recompute on a copy. }
program vect_alias_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c,ref: array of single; i: longint;
begin
  SetLength(b,n); SetLength(c,n); SetLength(ref,n);
  for i:=0 to n-1 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;
  for i:=0 to n-1 do ref[i]:=b[i]+c[i];  { expected }
  a:=b;                                  { a and b now share the block }
  for i:=0 to n-1 do a[i]:=a[i]+c[i];    { full self-alias, same index }
  for i:=0 to n-1 do if a[i]<>ref[i] then Halt(1);
end;
var k: longint;
begin
  for k:=0 to 13 do work(k);
  work(129);
end.
