{ %OPT="-O4 -OoNOREE" }
{ Control for optree_correct_01: the SAME redundant-extension shapes compiled
  with -OoREE explicitly disabled (every other -O4 optimization still on).  The
  redundant movzx/movsx are left in place and the program must still produce the
  identical results, proving REE is behaviour-preserving and that correct_01's
  results are not an accident of the pass masking a bug elsewhere.  Halt(nonzero)
  = failure. }
program optree_disabled_01;
{$mode objfpc}{$H+}

var
  g: longword;

function maskwiden(x: longword): qword; noinline;
begin
  x := x and $ff;
  g := x + 1;
  maskwiden := qword(byte(x));
end;

function maskwiden16(x: longword): qword; noinline;
begin
  x := x and $ffff;
  g := x + 3;
  maskwiden16 := qword(word(x));
end;

function sumbytes(const a: array of byte): longint; noinline;
var
  i, s: longint;
begin
  s := 0;
  for i := 0 to high(a) do
    s := s + a[i];
  sumbytes := s;
end;

var
  b: array[0..3] of byte;
begin
  g := 0;
  b[0] := 0; b[1] := 127; b[2] := 128; b[3] := 255;

  if sumbytes(b) <> (0+127+128+255) then Halt(1);
  if maskwiden($1234abff) <> 255 then Halt(2);
  if maskwiden($100) <> 0 then Halt(3);
  if maskwiden($7f) <> 127 then Halt(4);
  if maskwiden16($1234abcd) <> $abcd then Halt(5);
  if maskwiden16($10000) <> 0 then Halt(6);

  Halt(0);
end.
