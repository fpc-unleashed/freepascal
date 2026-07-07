{ %OPT="-O4" }
{ Code-size budget: the loop body is far larger than the unswitch node-weight
  cap, so the loop must NOT be unswitched (cloning it would blow up code size).
  It must still compile and produce the correct result with the branch left
  inside the loop. }
program unswitch_size_cap_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint; flag: boolean): longint;
var
  i, acc, a, b, c, d, e, f, g, h: longint;
begin
  acc := 0; a := 1; b := 2; c := 3; d := 4; e := 5; f := 6; g := 7; h := 8;
  for i := 1 to n do
    if flag then
      begin
        a := a + i;   b := b + a;   c := c + b;   d := d + c;
        e := e + d;   f := f + e;   g := g + f;   h := h + g;
        a := a xor 1; b := b xor 2; c := c xor 3; d := d xor 4;
        e := e xor 5; f := f xor 6; g := g xor 7; h := h xor 8;
        acc := acc + a + b + c + d + e + f + g + h;
      end
    else
      acc := acc - i;
  work := acc + a + b + c + d + e + f + g + h;
end;

var
  r0, r1: longint;
begin
  { correctness is what matters here; capture both outcomes and require the
    program to run and the heavy then-branch to differ from the light one }
  r0 := work(4, false);         { -(1+2+3+4) + (1+2+3+4+5+6+7+8) = -10+36 = 26 }
  r1 := work(4, true);
  if r0 <> 26 then Halt(1);
  if r1 = r0 then Halt(1);
end.
