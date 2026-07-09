{ %OPT="-O2 -OoSTACKALLOC" }
program stackalloc_escape_return_01;
{$mode objfpc}
type TA = array of longint;
{ An array assigned to the function result ESCAPES; it must not be stack-
  allocated, and returning it must still work. }
function make: TA;
var i: longint;
begin
  SetLength(result,5);
  for i:=0 to 4 do result[i]:=i+1;
end;
var b: TA; i,s: longint;
begin
  b:=make;
  if Length(b)<>5 then Halt(1);
  s:=0; for i:=0 to 4 do inc(s,b[i]);
  if s<>15 then Halt(2);
end.
