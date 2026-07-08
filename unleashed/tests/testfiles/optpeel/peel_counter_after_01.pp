{ %OPT="-O4 -OoLOOPPEEL" }
{ The peeled loop must leave the counter with the same post-loop value a normal
  for-loop leaves: the last taken index (the "to" bound) when the loop ran, and
  the counter untouched when the loop is statically empty (constant lo>hi, which
  the pass declines, so the ordinary for-loop -- which never assigns the counter
  -- is what runs). Bodies are sized into the peel window. }
program peel_counter_after_01;
{$mode objfpc}{$H+}

function asc(var a: array of longint): longint;
var i: longint;
begin
  for i:=0 to 7 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
  { after an ascending loop that ran, i = hi = 7 }
  asc:=i;
end;

function desc(var a: array of longint): longint;
var i: longint;
begin
  for i:=6 downto 2 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
  { after a descending loop that ran, i = to-bound = 2 }
  desc:=i;
end;

function empty: longint;
var i: longint; a: array[0..7] of longint;
begin
  i:=12345;
  { lo>hi constant: loop never runs, counter must stay 12345 }
  for i:=5 to 2 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
  empty:=i;
end;

var a: array[0..7] of longint;
begin
  if asc(a)<>7 then Halt(1);
  if desc(a)<>2 then Halt(2);
  if empty<>12345 then Halt(3);
  writeln('ok');
end.
