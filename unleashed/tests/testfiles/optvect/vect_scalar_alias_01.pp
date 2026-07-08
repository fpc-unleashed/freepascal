{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ The scalar-broadcast and copy shapes stay alias-safe when a and b reference
  the same dynamic-array block (a:=b): the packed load of the window precedes
  the store, and the scalar s is a distinct variable, so a[i]:=a[i]+s and the
  self-copy a[i]:=a[i] compute each lane from the old value exactly as the
  scalar loop would. Verified bit-exact against a scalar recompute on a copy. }
program vect_scalar_alias_01;
{$mode objfpc}{$H+}
procedure work(n: longint; s: single);
var a,b,ref: array of single; i: longint;
begin
  SetLength(b,n); SetLength(ref,n);
  for i:=0 to n-1 do b[i]:=i*0.5+1;

  for i:=0 to n-1 do ref[i]:=b[i]+s;   { expected for the scalar case }
  a:=b;                                { a and b now share the block }
  for i:=0 to n-1 do a[i]:=a[i]+s;     { full self-alias + broadcast scalar }
  for i:=0 to n-1 do if a[i]<>ref[i] then Halt(1);

  for i:=0 to n-1 do ref[i]:=s-b[i];   { non-commutative, expected }
  a:=b;
  for i:=0 to n-1 do a[i]:=s-a[i];     { self-alias, non-commutative }
  for i:=0 to n-1 do if a[i]<>ref[i] then Halt(2);

  a:=b;                                { self-copy over a shared block }
  for i:=0 to n-1 do a[i]:=a[i];
  for i:=0 to n-1 do if a[i]<>b[i] then Halt(3);
end;
var k: longint;
begin
  for k:=0 to 13 do work(k, 4.0);
  work(129, -2.5);
end.
