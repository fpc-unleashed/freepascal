{ %OPT="-O4 -OoPURE" }
{ -OoPURE proves `square` const (its result depends only on its by-value
  parameter, no global reads, no side effects), so -OoLICM may hoist the two
  identical calls square(k) with a loop-invariant argument out of the loop and
  common them to a single evaluation. The result must be unchanged whether or
  not the calls are hoisted. }
program optpure_hoist_01;
{$mode objfpc}

function square(x: longint): longint;
begin
  square := x * x;
end;

function work(n: longint): longint;
var
  i, k, acc: longint;
begin
  k := n + 7;
  acc := 0;
  for i := 1 to 100 do
    acc := acc + square(k) + square(k);   { 100 * 2 * 49 = 9800 }
  work := acc;
end;

begin
  if work(0) <> 9800 then Halt(1);
  if work(3) <> 100 * 2 * 100 then Halt(2);  { k=10 -> 100*2*100 = 20000 }
end.
