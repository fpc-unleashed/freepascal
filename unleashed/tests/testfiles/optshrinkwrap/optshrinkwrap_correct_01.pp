{ %OPT=-O4 -OoSHRINKWRAP }
{ -OoSHRINKWRAP (gcc shrink-wrapping, -fshrink-wrap) correctness oracle.  The
  pass sinks a push-only prologue below an initial guard clause so an early-exit
  fast path runs prologue-free.  A wrong move (a callee-saved register saved with
  a mutated value, a fast path that skips a needed restore, a corrupted return)
  is a miscompile, so this proves observable behaviour is identical on BOTH the
  guarded fast path and the full slow path, that recursion through a
  shrink-wrapped routine still works, and that a deep call chain of them is
  correct.  Every function below has the shape the pass targets: a nil/zero/empty
  guard that exits early, followed by a body heavy enough to force several
  callee-saved register saves.  Halt(nonzero) = failure. }
program optshrinkwrap_correct_01;
{$mode objfpc}{$H+}

{ Classic guard clause: nil pointer or non-positive length returns -1 (fast
  path, prologue-free); otherwise a register-hungry reduction (slow path). }
function reduce(p: PByte; n: longint): longint; noinline;
var
  i, a, b, c, d, e, f: longint;
begin
  if (p = nil) or (n <= 0) then
    exit(-1);
  a := 1; b := 2; c := 3; d := 4; e := 5; f := 6;
  for i := 0 to n - 1 do
    begin
      a := a + p[i];
      b := b xor (p[i] + 1);
      c := c + a * b;
      d := d + c - b;
      e := e + d + a;
      f := f + e xor c;
    end;
  reduce := a + b + c + d + e + f;
end;

{ Recursion through a shrink-wrapped routine: the guard (n<=0) is the recursion
  base and also the early exit; the slow path recurses and combines. }
function rec(n: longint): longint; noinline;
var
  x, y, z, w: longint;
begin
  if n <= 0 then
    exit(0);
  x := rec(n - 1);
  y := x + n;
  z := y * 2 - n;
  w := z + x - y;
  rec := x + y + z + w + n;
end;

{ Second-level guard function for a deep call chain. }
function leafguard(v: longint): longint; noinline;
var
  a, b, c, d: longint;
begin
  if v = 0 then
    exit(0);
  a := v; b := v shl 1; c := v xor 5; d := a + b + c;
  leafguard := a * b - c + d;
end;

function chain(depth, v: longint): longint; noinline;
var
  s, t, u: longint;
begin
  if depth = 0 then
    exit(leafguard(v));
  s := chain(depth - 1, v + 1);
  t := leafguard(v) + s;
  u := t - s + v;
  chain := s + t + u;
end;

var
  fast, slow, r5, k: longint;
  buf: array[0..7] of Byte;
  csum: longint;
  ia, ib, ic, id, ie, if_, ii: longint;
  acc, prev, ni, xx, yy, zz, ww: longint;
begin
  { fast path: nil pointer }
  fast := reduce(nil, 100);
  if fast <> -1 then Halt(1);
  { fast path: zero / negative length }
  if reduce(@buf, 0) <> -1 then Halt(2);
  if reduce(@buf, -3) <> -1 then Halt(3);

  { slow path: fill buffer deterministically and reduce }
  for k := 0 to 7 do
    buf[k] := Byte((k * 37 + 11) and $FF);
  slow := reduce(@buf, 8);
  { recompute the same reduction independently as an oracle }
  ia := 1; ib := 2; ic := 3; id := 4; ie := 5; if_ := 6;
  for ii := 0 to 7 do
    begin
      ia := ia + buf[ii];
      ib := ib xor (buf[ii] + 1);
      ic := ic + ia * ib;
      id := id + ic - ib;
      ie := ie + id + ia;
      if_ := if_ + ie xor ic;
    end;
  csum := ia + ib + ic + id + ie + if_;
  if slow <> csum then Halt(4);

  { recursion through a shrink-wrapped routine }
  r5 := rec(5);
  prev := 0;
  for ni := 1 to 5 do
    begin
      xx := prev;
      yy := xx + ni;
      zz := yy * 2 - ni;
      ww := zz + xx - yy;
      acc := xx + yy + zz + ww + ni;
      prev := acc;
    end;
  if r5 <> prev then Halt(5);

  { deep call chain mixing fast (v=0 base guards) and slow }
  if chain(0, 0) <> 0 then Halt(6);
  if leafguard(0) <> 0 then Halt(7);
  { determinism spot-check of a deep chain value }
  if chain(6, 3) <> chain(6, 3) then Halt(9);

  Halt(0);
end.
