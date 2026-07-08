{ %OPT="-O4 -OoPURE" }
{ Transitive const: `poly` calls `square`, both const. The bottom-up analysis
  must prove `square` const first (compiled earlier) and then `poly` const via
  its callee, so a call to `poly` with an invariant argument is hoistable.
  Correctness must hold regardless of hoisting. }
program optpure_chain_01;
{$mode objfpc}

function square(x: longint): longint;
begin
  square := x * x;
end;

function poly(x: longint): longint;
begin
  poly := square(x) + square(x + 1) + 3;
end;

function work(n: longint): longint;
var
  i, k, acc: longint;
begin
  k := n + 5;
  acc := 0;
  for i := 1 to 50 do
    acc := acc + poly(k);      { k=5 -> 25 + 36 + 3 = 64; 50*64 = 3200 }
  work := acc;
end;

begin
  if work(0) <> 3200 then Halt(1);
end.
