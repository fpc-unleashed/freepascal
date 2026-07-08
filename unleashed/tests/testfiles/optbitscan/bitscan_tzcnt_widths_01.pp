{ %OPT="-O4" }
{ Count-trailing-zeros idiom across the narrow widths (8/16-bit) and a signed
  32-bit case. 8/16-bit operands are integer-promoted by the front end and fall
  through to the (correct) scalar loop; the signed 32-bit case is lowered like
  the unsigned one (shr is logical in FPC, so the trailing-zero count is
  sign-independent). Either way the result must be bit-identical to an
  independent reference -- this pins the fallback and the signed path. }
program bitscan_tzcnt_widths_01;
{$mode objfpc}

function tz8(x: byte): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); x := x shr 1 end;
  tz8 := c;
end;

function tz16(x: word): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); x := x shr 1 end;
  tz16 := c;
end;

{ signed 32-bit: shr is a logical shift in FPC, so trailing-zero count is
  sign-independent; the dominating x<>0 gate still applies }
function tzs32(x: longint): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); x := x shr 1 end;
  tzs32 := c;
end;

function refbits(x: qword; width: longint): longint;
var i: longint;
begin
  if x = 0 then exit(0);
  i := 0;
  while ((x shr i) and 1) = 0 do inc(i);
  refbits := i;
end;

var
  i: longint;
begin
  if tz8(0) <> 0 then Halt(1);
  if tz16(0) <> 0 then Halt(2);
  if tzs32(0) <> 0 then Halt(3);

  for i := 0 to 7 do
    if tz8(byte(1 shl i)) <> i then Halt(10 + i);
  for i := 0 to 15 do
    if tz16(word(1 shl i)) <> i then Halt(30 + i);
  for i := 0 to 30 do
    if tzs32(longint(1) shl i) <> i then Halt(60 + i);

  { full 8-bit sweep }
  for i := 1 to 255 do
    if tz8(byte(i)) <> refbits(qword(byte(i)), 8) then Halt(4);
  { full 16-bit sweep }
  for i := 1 to 65535 do
    if tz16(word(i)) <> refbits(qword(word(i)), 16) then Halt(5);

  { signed edge: High(longint) is odd -> 0; -2 (…1110) -> 1; Low(longint) -> 31 }
  if tzs32(High(longint)) <> 0 then Halt(6);
  if tzs32(-2) <> 1 then Halt(7);
  if tzs32(Low(longint)) <> 31 then Halt(8);
end.
