{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_managed_elem_01;
{$mode objfpc}{$H+}
{ A dynamic array of a MANAGED element type (ansistring) is never stack-
  allocated (its elements must be finalized); behaviour must stay correct. }
function joinlen: longint;
var a: array of ansistring; i,s: longint;
begin
  SetLength(a,3);
  a[0]:='ab'; a[1]:='cde'; a[2]:='f';
  s:=0; for i:=0 to High(a) do inc(s,Length(a[i]));
  joinlen:=s;
end;
begin
  if joinlen<>6 then Halt(1);
end.
