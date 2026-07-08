{ %OPT="-O4 -OoLOOPPEEL -vn" }
{ Boundary trip counts and budget edges (loops in procedures so the counter is a
  simple local the pass can act on). Trip 1 (whoever unrolls it) runs the body
  exactly once; trip 8 is the peel limit and must peel; trip 9 exceeds the limit
  and is declined (note) yet stays correct; a body larger than the per-iteration
  budget is declined (note) yet stays correct. All declined loops must compute
  the identical result a scalar loop would. }
program peel_boundary_01;
{$mode objfpc}{$H+}

function g(i: longint): longint; inline;
begin
  g:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure trip1(var a: array of longint);
var i: longint;
begin
  for i:=4 to 4 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure trip8(var a: array of longint);
var i: longint;
begin
  for i:=0 to 7 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure trip9(var a: array of longint);
var i: longint;
begin
  for i:=0 to 8 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure bigbody(var a: array of longint);
var i: longint;
begin
  for i:=0 to 4 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + (i*i*i) - (i shl 1) + (i xor 7)
          + (i*5) - (i shl 3) + (i xor 1) + (i*i) - (i*11) + 13;
end;

procedure bigbody_ref(var a: array of longint; lo, hi: longint);
var i: longint;
begin
  for i:=lo to hi do
    a[i]:=i*i + (i shl 2) - (i xor 3) + (i*i*i) - (i shl 1) + (i xor 7)
          + (i*5) - (i shl 3) + (i xor 1) + (i*i) - (i*11) + 13;
end;

var
  a, ref: array[0..15] of longint;
  i: longint;
begin
  for i:=0 to 15 do a[i]:=-1;
  trip1(a);
  if a[4]<>g(4) then Halt(1);

  for i:=0 to 15 do a[i]:=-1;
  trip8(a);
  for i:=0 to 7 do if a[i]<>g(i) then Halt(2);

  for i:=0 to 15 do a[i]:=-1;
  trip9(a);
  for i:=0 to 8 do if a[i]<>g(i) then Halt(3);

  for i:=0 to 15 do begin a[i]:=-1; ref[i]:=-1; end;
  bigbody(a);
  bigbody_ref(ref, 0, 4);
  for i:=0 to 4 do if a[i]<>ref[i] then Halt(4);

  writeln('ok');
end.
