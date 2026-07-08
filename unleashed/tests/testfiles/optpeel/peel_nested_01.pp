{ %OPT="-O4 -OoLOOPPEEL -vn" }
{ Nested constant-trip loops. The pass runs in postorder, so an inner peelable
  loop is peeled before the outer body it sits in is duplicated. Both the
  inner-only and the fully-nested shapes must stay correct. Bodies are kept
  small so the nested growth stays inside the peel budget. }
program peel_nested_01;
{$mode objfpc}{$H+}

{ inner loop peels; outer loop has a variable bound so it does not }
procedure inner_only(var m: array of longint; rows: longint);
var r, c: longint;
begin
  for r:=0 to rows-1 do
    for c:=0 to 2 do
      m[r*3+c]:=(r+1)*(c+1) + (c xor 1);
end;

{ both loops constant small trip -> both peel }
procedure both(var m: array of longint);
var r, c: longint;
begin
  for r:=0 to 2 do
    for c:=0 to 2 do
      m[r*3+c]:=(r+1)*(c+1) + (c xor 1);
end;

function expect(r, c: longint): longint;
begin
  expect:=(r+1)*(c+1) + (c xor 1);
end;

var m: array[0..8] of longint; r, c: longint;
begin
  for r:=0 to 8 do m[r]:=-1;
  inner_only(m, 3);
  for r:=0 to 2 do for c:=0 to 2 do
    if m[r*3+c]<>expect(r,c) then Halt(1);

  for r:=0 to 8 do m[r]:=-1;
  both(m);
  for r:=0 to 2 do for c:=0 to 2 do
    if m[r*3+c]<>expect(r,c) then Halt(2);

  writeln('ok');
end.
