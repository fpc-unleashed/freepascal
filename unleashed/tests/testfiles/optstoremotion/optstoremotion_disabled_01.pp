{ %OPT="-O4 -OoNOSTOREMOTION" }
{ Control for optstoremotion_correct_01: the identical logic compiled with loop
  store motion DISABLED (-OoNOSTOREMOTION).  Every result must be byte-for-byte
  identical to the enabled build, proving the transform relocates only WHERE the
  global's load/store happens (once before / once after the loop instead of
  every iteration), never WHAT the program computes.  Halts with the check
  number on any mismatch. }
program optstoremotion_disabled_01;
{$mode objfpc}{$H+}

var
  g, g2, gbound: longint;
  gd: double;

{ noinline getters keep the globals memory-resident (not whole-proc regvars),
  so the accumulators genuinely load/store memory without the pass }
function peek: longint; noinline; begin peek := g; end;
function peek2: longint; noinline; begin peek2 := g2; end;
function peekd: double; noinline; begin peekd := gd; end;

{ --- promotable shapes --- }

{ plain for-loop accumulation into a global }
procedure acc_for(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    g := g + i * 2;
end;

{ while-loop accumulation }
procedure acc_while(n: longint); noinline;
var i: longint;
begin
  i := 0;
  while i < n do
    begin
      g := g + i;
      i := i + 1;
    end;
end;

{ repeat-loop accumulation (always at least one trip) }
procedure acc_repeat(n: longint); noinline;
var i: longint;
begin
  i := 0;
  repeat
    g := g + 1;
    i := i + 1;
  until i >= n;
end;

{ conditional write: g updated on only some iteration paths }
procedure acc_cond(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    if (i and 1) = 1 then
      g := g + i;
end;

{ two globals promoted in the same loop }
procedure acc_two(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    begin
      g := g + i;
      g2 := g2 - i;
    end;
end;

{ a global as the loop bound while another global is promoted }
procedure acc_gbound; noinline;
var i: longint;
begin
  for i := 1 to gbound do
    g := g + i;
end;

{ floating-point global accumulation }
procedure acc_double(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    gd := gd + 1.5;
end;

{ --- shapes the pass must DECLINE (correctness must still hold) --- }

procedure noteupper(x: longint); noinline; begin if x = -12345 then Writeln(x); end;

{ call inside the loop -> declined (a call may read/write the global) }
procedure decl_call(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    begin
      g := g + i;
      noteupper(g);
    end;
end;

{ aliasing pointer store inside the loop -> declined }
procedure decl_ptr(n: longint; p: plongint); noinline;
var i: longint;
begin
  for i := 1 to n do
    begin
      g := g + i;
      p^ := g;
    end;
end;

{ break inside the loop -> declined (procedure has a label) }
procedure decl_break(n: longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    begin
      g := g + i;
      if g > 100000 then
        break;
    end;
end;

{ indexed store inside the loop -> declined }
procedure decl_idx(n: longint; var a: array of longint); noinline;
var i: longint;
begin
  for i := 1 to n do
    begin
      g := g + i;
      a[i mod 4] := g;
    end;
end;

{ nested loop -> declined (v1 handles no nested loops) }
procedure decl_nested(n: longint); noinline;
var i, j: longint;
begin
  for i := 1 to n do
    for j := 1 to n do
      g := g + 1;
end;

{ Expected values are hand-computed COMPILE-TIME CONSTANTS rather than results
  of a reference loop, so the oracle itself is never subject to any loop
  optimization: acc_for(n) adds  i*2  for i in 1..n  ==>  delta = n*(n+1). }

var
  arr: array[0..3] of longint;
  target: longint;
begin
  { for-loop, several trip counts }
  g := 100; acc_for(5);   if peek <> 130 then Halt(1);            { 100 + 5*6 }
  g := 100; acc_for(0);   if peek <> 100 then Halt(2);            { zero-trip: unchanged }
  g := 100; acc_for(-4);  if peek <> 100 then Halt(3);            { negative bound: zero-trip }
  g := 100; acc_for(1);   if peek <> 102 then Halt(4);            { single trip }
  g := 7;   acc_for(1000);if peek <> 1001007 then Halt(5);        { 7 + 1000*1001 }

  { while }
  g := 0; acc_while(10);  if peek <> 45 then Halt(6);
  g := 0; acc_while(0);   if peek <> 0 then Halt(7);              { zero-trip }

  { repeat (min one trip) }
  g := 0; acc_repeat(5);  if peek <> 5 then Halt(8);
  g := 0; acc_repeat(0);  if peek <> 1 then Halt(9);              { repeat runs once }

  { conditional write: sum of odd i in 1..9 = 1+3+5+7+9 = 25 }
  g := 3; acc_cond(9);    if peek <> 28 then Halt(10);            { 3 + 25 }
  g := 3; acc_cond(0);    if peek <> 3 then Halt(11);

  { two globals in one loop }
  g := 0; g2 := 0; acc_two(6);
  if (peek <> 21) or (peek2 <> -21) then Halt(12);
  g := 0; g2 := 0; acc_two(0);
  if (peek <> 0) or (peek2 <> 0) then Halt(13);

  { global bound + promoted global }
  gbound := 8; g := 0; acc_gbound; if peek <> 36 then Halt(14);
  gbound := 0; g := 55; acc_gbound; if peek <> 55 then Halt(15);

  { double }
  gd := 0.0; acc_double(4); if peekd <> 6.0 then Halt(16);
  gd := 2.0; acc_double(0); if peekd <> 2.0 then Halt(17);

  { declined shapes still correct }
  g := 0; decl_call(5);   if peek <> 15 then Halt(18);
  g := 0; decl_call(0);   if peek <> 0 then Halt(19);

  target := 0; g := 0; decl_ptr(4, @target);
  if (peek <> 10) or (target <> 10) then Halt(20);

  g := 0; decl_break(5);  if peek <> 15 then Halt(21);

  arr[0] := 0; arr[1] := 0; arr[2] := 0; arr[3] := 0;
  g := 0; decl_idx(5, arr);
  if peek <> 15 then Halt(22);

  g := 0; decl_nested(4); if peek <> 16 then Halt(23);

  Halt(0);
end.
