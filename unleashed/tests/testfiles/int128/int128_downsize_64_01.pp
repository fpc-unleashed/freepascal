program int128_downsize_64_01;

{ a 128 bit intermediate downcast to 64 bit or less may be reduced to
  64 bit arithmetic; the reduction must skip shifts whose count reaches
  64 (it would get masked) and shr on sign-extended values (the
  extension bits get shifted in); inline expansion substitutes constant
  arguments and exposes all of it }

{$mode unleashed}
{$inline on}

function mulcut(x, y: Int128): QWord; inline;
begin
  result := QWord(x * y);
end;

function divcut(x, y: Int128): QWord; inline;
begin
  result := QWord(x div y);
end;

function addcut(x, y: Int128): QWord; inline;
begin
  result := QWord(x + y);
end;

function shrbig(q: UInt128): QWord; inline;
begin
  result := QWord(q shr 64);
end;

function shlbig(q: UInt128): QWord; inline;
begin
  result := QWord(q shl 64);
end;

function shrsigned(q: Int128): QWord; inline;
begin
  result := QWord(q shr 4);
end;

function shrvar(q: UInt128; c: DWord): QWord; inline;
begin
  result := QWord(q shr c);
end;

var
  r: QWord;
  c: DWord;
begin
  { reduced product must keep the exact low 64 bits:
    10^10 * (3*10^10 + 7) mod 2^64 }
  r := mulcut(10000000000, 30000000007);
  if r <> 4852094890647174144 then halt(1);
  r := divcut(18446744073709551615, 3);
  if r <> 6148914691236517205 then halt(2);
  r := addcut(18446744073709551615, 2);
  if r <> 1 then halt(3);

  { count reaching 64 must stay a 128 bit shift, a reduced one would
    mask the count to 0 }
  r := shrbig(1);
  if r <> 0 then halt(4);
  r := shlbig(1);
  if r <> 0 then halt(5);

  { sign-extended value must stay a 128 bit shr }
  r := shrsigned(-1);
  if r <> $FFFFFFFFFFFFFFFF then halt(6);

  { variable count never reduces }
  c := 80;
  r := shrvar(1000000, c);
  if r <> 0 then halt(7);
end.
