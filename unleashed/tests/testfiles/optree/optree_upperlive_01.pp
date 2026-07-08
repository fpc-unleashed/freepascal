{ %OPT=-O4 }
{ -OoREE conservativeness oracle: cases where the extension is NOT redundant and
  MUST be kept.  If the pass wrongly deleted any of these the observable result
  would change, so a clean Halt(0) proves the "every reaching definition already
  guarantees the extension" test really is required and the recognizer defaults
  to keeping the extension whenever the source's high bits are genuinely live or
  produced by something it does not model (a 32-bit ALU result, a partial write,
  a definition reached only across a label). }
program optree_upperlive_01;
{$mode objfpc}{$H+}

var
  g: longword;

{ The byte extraction follows a 32-bit add whose upper bits are non-zero, so the
  movzbl is load-bearing: deleting it would return the full 32-bit sum. }
function bytelow(x: longword): longword; noinline;
begin
  x := x + $500;
  bytelow := byte(x);
end;

{ Sign extraction after a 32-bit op: movsx must survive; otherwise the top bits
  of the 32-bit value would leak. }
function shortlow(x: longint): longint; noinline;
begin
  x := x * 3 + 1;
  shortlow := shortint(x);
end;

{ Same register serves two different extension widths in turn.  Neither widening
  may be dropped: the byte view and the word view differ. }
function bothviews(x: longword): longword; noinline;
var
  lo, mid: longword;
begin
  x := x xor $0f0f0f0f;
  lo := byte(x);         { needs zero-extension from 8 }
  mid := word(x);        { needs zero-extension from 16 -- different requirement }
  bothviews := lo + mid * 65536;
end;

{ A definition (the and) is separated from the widening use by a branch/label, so
  the pass cannot enumerate the reaching definitions and must keep the extension.
  It also must stay correct when the branch is taken (y redefined by a byte add
  whose high bits, though zero here, the pass may not assume). }
function branched(x: longword): longword; noinline;
var
  y: byte;
begin
  y := byte(x and $ff);
  if g > 0 then
    y := y + 1;
  branched := longword(y);
end;

begin
  g := 0;

  if bytelow($abcd12) <> ((($abcd12 + $500) and $ff)) then Halt(1);
  if bytelow($0) <> $00 then Halt(2);
  if bytelow($fb) <> (($fb + $500) and $ff) then Halt(4);

  if shortlow(100) <> longint(shortint((100*3+1) and $ff)) then Halt(5);
  if shortlow(-100) <> longint(shortint((-100*3+1) and $ff)) then Halt(6);
  if shortlow(42) <> longint(shortint((42*3+1) and $ff)) then Halt(7);

  if bothviews($12345678) <> ((($12345678 xor $0f0f0f0f) and $ff)
       + (($12345678 xor $0f0f0f0f) and $ffff) * 65536) then Halt(8);

  g := 0;
  if branched($1234ff) <> $ff then Halt(9);
  g := 5;
  if branched($1234fe) <> $ff then Halt(10);  { $fe -> +1 = $ff }
  if branched($123480) <> $81 then Halt(11);

  Halt(0);
end.
