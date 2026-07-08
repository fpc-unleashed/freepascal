{ %OPT="-O4" }
{ Highest-set-bit (bsr / floor-log2) bit-scan idiom (-OoBITIDIOM extension).
  The self-guarding unsigned scan

      while x > 1 do begin inc(c); x := x shr 1 end;

  is lowered to a Bsr/Lzcnt-based intrinsic at -O4. Unlike the tzcnt shape this
  loop is total (zero-trip for x in {0,1}), so no external guard is needed; the
  rewrite's own  if x<>0  reproduces the x=0 no-op. Value-identity is checked
  against an independent reference for single-bit values, dense values, High/Low
  and the x in {0,1} boundary, for 8/16/32/64-bit unsigned x. }
program bitscan_bsr_01;
{$mode objfpc}

function bsr8(x: byte): longint;
var c: longint;
begin c := 0; while x > 1 do begin inc(c); x := x shr 1 end; bsr8 := c; end;

function bsr16(x: word): longint;
var c: longint;
begin c := 0; while x > 1 do begin inc(c); x := x shr 1 end; bsr16 := c; end;

function bsr32(x: dword): longint;
var c: longint;
begin c := 0; while x > 1 do begin inc(c); x := x shr 1 end; bsr32 := c; end;

function bsr64(x: qword): longint;
var c: longint;
begin c := 0; while x > 1 do begin inc(c); x := x shr 1 end; bsr64 := c; end;

function refbsr(x: qword): longint;
var i: longint;
begin
  if x = 0 then exit(0);
  i := 0;
  while (x shr (i + 1)) <> 0 do inc(i);
  refbsr := i;
end;

var
  i: longint;
  x: qword;
begin
  { boundary: x in {0,1} -> zero-trip -> c=0 }
  if bsr8(0) <> 0 then Halt(1);
  if bsr8(1) <> 0 then Halt(2);
  if bsr64(0) <> 0 then Halt(3);
  if bsr64(1) <> 0 then Halt(4);

  for i := 0 to 7 do
    if bsr8(byte(1 shl i)) <> i then Halt(10 + i);
  for i := 0 to 15 do
    if bsr16(word(1 shl i)) <> i then Halt(30 + i);
  for i := 0 to 31 do
    if bsr32(dword(1) shl i) <> i then Halt(60 + i);
  for i := 0 to 63 do
    if bsr64(qword(1) shl i) <> i then Halt(100 + i);

  if bsr8(High(byte)) <> 7 then Halt(5);
  if bsr16(High(word)) <> 15 then Halt(6);
  if bsr32(High(dword)) <> 31 then Halt(7);
  if bsr64(High(qword)) <> 63 then Halt(8);

  { full 16-bit sweep against reference }
  for i := 0 to 65535 do
    if bsr16(word(i)) <> refbsr(qword(word(i))) then Halt(9);

  { dense 64-bit sweep }
  for i := 1 to 200000 do
    begin
      x := qword(i) * qword(2654435761) + qword(i);
      if bsr64(x) <> refbsr(x) then Halt(20);
      if bsr32(dword(x)) <> refbsr(qword(dword(x))) then Halt(21);
    end;
end.
