{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_offon_equiv_01;
{$mode objfpc}
{ Element addresses passed by var to a callee: lifetime is frame-equivalent to
  the heap array, so the transform is still valid and results must match. }
procedure bump(var x: longint); begin x:=x+100; end;
function g: longint;
var a: array of longint; i,s: longint;
begin
  SetLength(a,6);
  for i:=0 to 5 do a[i]:=i;
  for i:=0 to 5 do bump(a[i]);
  s:=0; for i:=0 to 5 do inc(s,a[i]);
  g:=s;
end;
begin
  if g<>615 then Halt(1);
end.
