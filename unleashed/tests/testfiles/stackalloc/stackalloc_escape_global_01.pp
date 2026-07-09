{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_escape_global_01;
{$mode objfpc}
type TA = array of longint;
var g: TA;
{ Stored to a global -> escapes; must remain heap-allocated so it survives
  after the routine returns. }
procedure fill;
var a: TA; i: longint;
begin
  SetLength(a,4);
  for i:=0 to 3 do a[i]:=i*10;
  g:=a;
end;
var i,s: longint;
begin
  fill;
  if Length(g)<>4 then Halt(1);
  s:=0; for i:=0 to 3 do inc(s,g[i]);
  if s<>60 then Halt(2);
end.
