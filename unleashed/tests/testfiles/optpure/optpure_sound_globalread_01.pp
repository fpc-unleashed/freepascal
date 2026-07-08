{ %OPT="-O4 -OoPURE" }
{ Soundness: a function that READS a global is "pure" but NOT "const", so LICM
  (which requires const) must not hoist it out of a loop that modifies that
  global -- otherwise it would freeze a stale value. Here `g` changes every
  iteration and `readg` returns it; the sum must reflect each per-iteration
  value (1+2+...+100 = 5050). A wrong const attribution would give 100*first. }
program optpure_sound_globalread_01;
{$mode objfpc}

var
  g: longint;

function readg(x: longint): longint;
begin
  readg := x + g;              { global read => pure but not const }
end;

function work: longint;
var
  i, acc: longint;
begin
  g := 0;
  acc := 0;
  for i := 1 to 100 do
    begin
      g := g + 1;              { g = i }
      acc := acc + readg(0);   { must read the current g each time }
    end;
  work := acc;
end;

begin
  if work <> 5050 then Halt(1);
end.
