{ %OPT="-O4 -OoLOOPSPLIT" }
{ The two split loops tile [lo,hi] contiguously, so the counter is left with
  exactly the value a single for-loop leaves: the "to" bound hi when the loop
  ran (whichever sub-loop ran last), and untouched when the loop never ran.
  Verified for crossovers at both range ends (all-low, all-high) and inside. }
program split_counter_after_01;
{$mode objfpc}{$H+}

function ran(var a: array of longint; n,m: longint): longint;
var i: longint;
begin
  i:=-777;
  for i:=0 to n-1 do
    if i<m then a[i]:=1 else a[i]:=2;
  ran:=i;
end;

function empty(m: longint): longint;
var i: longint; a: array[0..3] of longint;
begin
  i:=54321;
  { hi = -1 < lo = 0: loop never runs, counter must stay 54321 }
  for i:=0 to -1 do
    if i<m then a[i]:=1 else a[i]:=2;
  empty:=i;
end;

var a: array[0..15] of longint;
begin
  { m below range (all high branch), inside, above range (all low branch) }
  if ran(a,10,-5)<>9 then Halt(1);
  if ran(a,10,4)<>9  then Halt(2);
  if ran(a,10,99)<>9 then Halt(3);
  if ran(a,1,0)<>0   then Halt(4);
  if empty(3)<>54321 then Halt(5);
  writeln('ok');
end.
