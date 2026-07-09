{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_nonescape_semantics_01;
{$mode objfpc}
{ A non-escaping local dynamic array with a constant-length SetLength is
  stack-allocated; behaviour (zero-fill on alloc, indexing, Length/High) must
  be identical to the heap version. }
function sumsq: longint;
var a: array of longint; i,s: longint;
begin
  SetLength(a,8);
  { newly allocated elements must be zero }
  for i:=0 to High(a) do if a[i]<>0 then Halt(1);
  if Length(a)<>8 then Halt(2);
  if High(a)<>7 then Halt(3);
  for i:=0 to High(a) do a[i]:=i*i;
  s:=0; for i:=0 to Length(a)-1 do inc(s,a[i]);
  sumsq:=s;
end;
begin
  if sumsq<>140 then Halt(4);
end.
