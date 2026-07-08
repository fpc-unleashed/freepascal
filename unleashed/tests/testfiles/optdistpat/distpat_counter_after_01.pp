{ %OPT="-O4 -OoLOOPDISTPAT" }
{ The lowered loop must leave the counter with the same post-loop value a normal
  ascending for-loop leaves: the last taken index hi when the loop ran, and the
  counter untouched when the loop never ran (lo>hi). These values are compared
  against the exact constants a scalar for-loop produces on this compiler. }
program distpat_counter_after_01;
{$mode objfpc}{$H+}

function ran(n: longint): longint;
var a: array of longint; i: longint;
begin
  SetLength(a,n+1);
  i:=-999;
  for i:=0 to n do a[i]:=0;
  { after a for-loop that executed, i = hi = n }
  ran:=i + a[0];
end;

function empty: longint;
var a: array of longint; i: longint;
begin
  SetLength(a,3);
  i:=12345;
  { lo>hi: loop never runs, counter must stay 12345 }
  for i:=8 to 3 do a[i]:=0;
  empty:=i;
end;

begin
  if ran(0)<>0 then Halt(1);
  if ran(10)<>10 then Halt(2);
  if ran(1000)<>1000 then Halt(3);
  if empty<>12345 then Halt(4);
end.
