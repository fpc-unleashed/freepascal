{ %OPT="-O4 -OoNOPURE" }
{ Disabled control: with -OoNOPURE the purity pass never runs, so no call is
  hoisted/commoned, and the result must be byte-for-byte identical to the
  -OoPURE runs above. Guards against a switch-dependent behavioural difference. }
program optpure_disabled_01;
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
    acc := acc + square(k) + square(k);
  work := acc;
end;

begin
  if work(0) <> 9800 then Halt(1);
  if work(3) <> 20000 then Halt(2);
end.
