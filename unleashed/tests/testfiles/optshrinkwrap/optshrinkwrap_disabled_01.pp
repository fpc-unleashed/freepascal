{ %OPT=-O4 -OoSHRINKWRAP -OoNOSHRINKWRAP }
{ Control for optshrinkwrap_correct_01 / _regsurvive_01: the SAME shrink-wrappable
  guard-clause shapes compiled with -OoSHRINKWRAP explicitly disabled again by a
  trailing -OoNOSHRINKWRAP (every other -O4 optimization still on).  The prologue
  is emitted unconditionally at entry as usual, and the program must produce the
  identical results, proving the transform is behaviour-preserving and that the
  passing results elsewhere are not an accident of the pass masking a bug.
  Halt(nonzero) = failure. }
program optshrinkwrap_disabled_01;
{$mode objfpc}{$H+}

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

function guarded(p: PByte; n: longint): longint; noinline;
var
  i, a, b, c, d, e: longint;
begin
  if (p = nil) or (n <= 0) then
    exit(7);
  a := 0; b := 1; c := 2; d := 3; e := 4;
  for i := 0 to n - 1 do
    begin
      a := a + p[i]; b := b xor a; c := c + b - a; d := d + c; e := e + d xor b;
    end;
  guarded := a + b + c + d + e;
end;

var
  buf: array[0..7] of Byte;
  k, slow, csum: longint;
  ia, ib, ic, id, ie, if_, ii: longint;
  r, i: longint;
  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9: longint;
begin
  if reduce(nil, 100) <> -1 then Halt(1);
  if reduce(@buf, 0) <> -1 then Halt(2);

  for k := 0 to 7 do
    buf[k] := Byte((k * 37 + 11) and $FF);
  slow := reduce(@buf, 8);
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
  if slow <> csum then Halt(3);

  { register survival with the pass off (reference behaviour) }
  s0 := 1000; s1 := 1001; s2 := 1002; s3 := 1003; s4 := 1004;
  s5 := 1005; s6 := 1006; s7 := 1007; s8 := 1008; s9 := 1009;
  r := 0;
  for i := 1 to 400 do
    r := r + guarded(nil, i);
  if (s0 <> 1000) or (s1 <> 1001) or (s2 <> 1002) or (s3 <> 1003) or
     (s4 <> 1004) or (s5 <> 1005) or (s6 <> 1006) or (s7 <> 1007) or
     (s8 <> 1008) or (s9 <> 1009) then
    Halt(4);
  if r <> 400 * 7 then Halt(5);

  Halt(0);
end.
