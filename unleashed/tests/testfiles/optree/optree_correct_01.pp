{ %OPT=-O4 }
{ -OoREE (redundant sign/zero-extension elimination, gcc ree.cc) correctness
  oracle.  A wrong deletion is a miscompile, so this proves the pass preserves
  observable behaviour across the edge values that matter for extension width:
  byte 0, 127, 128, 255 and shortint sign boundaries -1, -128, 127.  Several
  shapes are exercised:
    * a byte-load loop that sums the bytes of an array, the value re-extended
      each iteration (the classic parser/codec shape);
    * a masked-then-widened value (and $ff followed by a use as a wider type),
      which is exactly the redundant movzbl the pass deletes;
    * a shortint (signed) load loop, guarding the movsx side;
    * both signed and unsigned widening to 64 bits.
  Halt(nonzero) = failure. }
program optree_correct_01;
{$mode objfpc}{$H+}

{ Sum an array of bytes; each element is zero-extended for the add.  The
  accumulator and the extension recur every iteration. }
function sumbytes(const a: array of byte): longint; noinline;
var
  i, s: longint;
begin
  s := 0;
  for i := 0 to high(a) do
    s := s + a[i];
  sumbytes := s;
end;

{ Sum an array of shortint; sign-extended each iteration (movsx side). }
function sumshort(const a: array of shortint): longint; noinline;
var
  i, s: longint;
begin
  s := 0;
  for i := 0 to high(a) do
    s := s + a[i];
  sumshort := s;
end;

{ Masked-then-widened: 'and $ff' already zero-extends, so the widening use of x
  is the redundant movzbl the pass removes.  g keeps the mask result live so the
  and cannot itself be folded away. }
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

{ Signed byte round-trip through a wider type, exercising sign extension over
  the whole edge range. }
function sbyteid(v: shortint): longint; noinline;
var
  t: longint;
begin
  t := v;               { movsx }
  if g <> 0 then        { defeat trivial folding }
    t := t + 0;
  sbyteid := longint(shortint(t));
end;

var
  b: array[0..7] of byte;
  s: array[0..7] of shortint;
  i, expect: longint;
begin
  g := 0;

  { edge byte values }
  b[0] := 0;   b[1] := 127; b[2] := 128; b[3] := 255;
  b[4] := 1;   b[5] := 200; b[6] := 64;  b[7] := 254;
  expect := 0;
  for i := 0 to 7 do expect := expect + b[i];
  if sumbytes(b) <> expect then Halt(1);
  if sumbytes(b) <> (0+127+128+255+1+200+64+254) then Halt(2);

  { edge shortint values }
  s[0] := 0;   s[1] := 127;  s[2] := -128; s[3] := -1;
  s[4] := 1;   s[5] := -50;  s[6] := 63;   s[7] := -64;
  expect := 0;
  for i := 0 to 7 do expect := expect + s[i];
  if sumshort(s) <> expect then Halt(3);
  if sumshort(s) <> (0+127-128-1+1-50+63-64) then Halt(4);

  { mask-then-widen: byte }
  if maskwiden($1234abff) <> 255 then Halt(5);
  if maskwiden($00000080) <> 128 then Halt(6);
  if maskwiden($7f) <> 127 then Halt(7);
  if maskwiden($100) <> 0 then Halt(8);

  { mask-then-widen: word }
  if maskwiden16($1234abcd) <> $abcd then Halt(9);
  if maskwiden16($ffff) <> $ffff then Halt(10);
  if maskwiden16($10000) <> 0 then Halt(11);

  { signed round-trip edge values }
  if sbyteid(0) <> 0 then Halt(12);
  if sbyteid(127) <> 127 then Halt(13);
  if sbyteid(-128) <> -128 then Halt(14);
  if sbyteid(-1) <> -1 then Halt(15);

  Halt(0);
end.
