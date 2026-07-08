{ %OPT="-O4 -vn" }
{ Loop peeling is part of the -O4 default optimizer set, so it fires without an
  explicit -OoLOOPPEEL. A constant small-trip loop with a medium body peels; the
  result must be correct. (Compiled at plain -O4; the note confirms the pass ran
  as a default.) }
program peel_o4_default_01;
{$mode objfpc}{$H+}

procedure k(var a: array of longint);
var i: longint;
begin
  for i:=0 to 5 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + (i*7) - 4;
end;

var a: array[0..7] of longint; i: longint;
begin
  for i:=0 to 7 do a[i]:=-1;
  k(a);
  for i:=0 to 5 do
    if a[i]<>i*i + (i shl 2) - (i xor 3) + (i*7) - 4 then Halt(1);
  if (a[6]<>-1) or (a[7]<>-1) then Halt(2);
  writeln('ok');
end.
