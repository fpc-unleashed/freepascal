{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_loop_guard_01;
{$mode objfpc}
{ SetLength executed repeatedly in a loop: like the RTL, a SetLength to the
  same length must be a no-op that RETAINS the data (not re-zero it). }
function f: longint;
var a: array of longint; i,k,s: longint;
begin
  s:=0;
  for k:=0 to 2 do
  begin
    SetLength(a,4);
    if k=0 then for i:=0 to 3 do a[i]:=i;
    inc(a[k]);
    inc(s,a[k]);
  end;
  for i:=0 to 3 do inc(s,a[i]);
  f:=s;
end;
begin
  if f<>15 then Halt(1);
end.
