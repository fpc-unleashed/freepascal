{ %OPT=-O4 -OoSHRINKWRAP }
{ THE miscompile risk for shrink-wrapping: a callee-saved register CLOBBERED on
  the fast path.  The pass sinks the pushes below the guard, so on the early-exit
  path the callee neither saves nor restores rbx/r12-r15; correctness depends on
  the fast path never touching them.

  sentinel_test is a direct probe: it holds ten sentinel values that the register
  allocator must keep live -- across a long loop of calls taken on the shrink-
  wrapped function's FAST path -- in callee-saved registers, then checks that
  every sentinel survived unchanged and every fast-path return value is correct.
  If a fast-path call trashed a caller's callee-saved register, a sentinel
  diverges and the function returns nonzero.

  mixed() additionally folds real fast/slow results into register-live
  accumulators and is checked against ref() -- the identical arithmetic with the
  guard bodies inlined (no call, hence no possible cross-call clobber), a strong
  value oracle independent of the pass.  Halt(nonzero) = failure. }
program optshrinkwrap_regsurvive_01;
{$mode objfpc}{$H+}

function guarded(p: PByte; n: longint): longint; noinline;
var
  i, a, b, c, d, e: longint;
begin
  if (p = nil) or (n <= 0) then
    exit(7);
  a := 0; b := 1; c := 2; d := 3; e := 4;
  for i := 0 to n - 1 do
    begin
      a := a + p[i];
      b := b xor a;
      c := c + b - a;
      d := d + c;
      e := e + d xor b;
    end;
  guarded := a + b + c + d + e;
end;

function guarded2(x: longint): longint; noinline;
var
  a, b, c, d, e, f, g: longint;
begin
  if x = 0 then
    exit(0);
  a := x; b := x + 1; c := x + 2; d := x + 3;
  e := x + 4; f := x + 5; g := x + 6;
  guarded2 := a xor b + c xor d + e xor f + g + a * b - c * d;
end;

{ Sentinels live across 400 fast-path calls; any callee-saved clobber shows up. }
function sentinel_test: longint;
var
  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9: longint;
  i, r: longint;
begin
  s0 := 1000; s1 := 1001; s2 := 1002; s3 := 1003; s4 := 1004;
  s5 := 1005; s6 := 1006; s7 := 1007; s8 := 1008; s9 := 1009;
  r := 0;
  for i := 1 to 400 do
    begin
      r := r + guarded(nil, i);        { fast path, must return 7, touch no CSR }
      r := r + guarded2(0);            { fast path, must return 0 }
    end;
  if (s0 <> 1000) or (s1 <> 1001) or (s2 <> 1002) or (s3 <> 1003) or
     (s4 <> 1004) or (s5 <> 1005) or (s6 <> 1006) or (s7 <> 1007) or
     (s8 <> 1008) or (s9 <> 1009) then
    exit(-1);
  if r <> 400 * 7 then
    exit(-2);
  sentinel_test := 0;
end;

function inl_guarded(pnil: Boolean; n: longint; b0, b1, b2, b3: longint): longint;
var
  i, a, b, c, d, e: longint;
begin
  if pnil or (n <= 0) then
    exit(7);
  a := 0; b := 1; c := 2; d := 3; e := 4;
  for i := 0 to n - 1 do
    begin
      case i and 3 of
        0: a := a + b0; 1: a := a + b1; 2: a := a + b2; else a := a + b3;
      end;
      b := b xor a;
      c := c + b - a;
      d := d + c;
      e := e + d xor b;
    end;
  inl_guarded := a + b + c + d + e;
end;

function inl_guarded2(x: longint): longint;
var
  a, b, c, d, e, f, g: longint;
begin
  if x = 0 then
    exit(0);
  a := x; b := x + 1; c := x + 2; d := x + 3;
  e := x + 4; f := x + 5; g := x + 6;
  inl_guarded2 := a xor b + c xor d + e xor f + g + a * b - c * d;
end;

function mixed(iters: longint; usecall: Boolean): longint;
var
  v0, v1, v2, v3, v4, v5, v6, v7, v8, v9: longint;
  i, r: longint;
  buf: array[0..3] of Byte;
begin
  buf[0] := 10; buf[1] := 20; buf[2] := 30; buf[3] := 40;
  v0 := 1; v1 := 2; v2 := 3; v3 := 4; v4 := 5;
  v5 := 6; v6 := 7; v7 := 8; v8 := 9; v9 := 10;
  for i := 1 to iters do
    begin
      if usecall then
        begin
          if (i and 7) = 0 then
            r := guarded(@buf, 4)
          else
            r := guarded(nil, i);
          v3 := v3 + guarded2((i and 3));
        end
      else
        begin
          if (i and 7) = 0 then
            r := inl_guarded(False, 4, 10, 20, 30, 40)
          else
            r := inl_guarded(True, i, 10, 20, 30, 40);
          v3 := v3 + inl_guarded2((i and 3));
        end;
      v0 := v0 + r;
      v1 := v1 xor (i + 1);
      v2 := v2 + v1 - i;
      v4 := v4 + v0;
      v5 := v5 xor v2;
      v6 := v6 + v3 - v4;
      v7 := v7 + v5;
      v8 := v8 xor v6;
      v9 := v9 + v7 - v8;
    end;
  mixed := v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9;
end;

var
  it: longint;
begin
  if sentinel_test <> 0 then
    Halt(1);
  for it := 0 to 30 do
    if mixed(40 + it, True) <> mixed(40 + it, False) then
      Halt(2);
  Halt(0);
end.
