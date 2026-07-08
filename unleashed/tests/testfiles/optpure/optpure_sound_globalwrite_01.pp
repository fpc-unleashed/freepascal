{ %OPT="-O4 -OoPURE" }
{ Soundness: a function that WRITES a global variable must not be treated as
  pure/const, so its calls are neither hoisted out of the loop nor commoned.
  The write is directly observable: `bump` is called twice per iteration for
  200 iterations, so the global side-effect counter must be exactly 200 and the
  accumulated result must reflect every call. A wrong purity attribution would
  under-count the side effects. }
program optpure_sound_globalwrite_01;
{$mode objfpc}

var
  calls: longint;

function bump(x: longint): longint;
begin
  calls := calls + 1;          { global write => impure }
  bump := x * x;
end;

function work(n: longint): longint;
var
  i, k, acc: longint;
begin
  k := n + 7;
  acc := 0;
  for i := 1 to 100 do
    acc := acc + bump(k) + bump(k);
  work := acc;
end;

begin
  calls := 0;
  if work(0) <> 9800 then Halt(1);
  if calls <> 200 then Halt(2);   { every call must have executed }
end.
