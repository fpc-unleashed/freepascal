{ %OPT="-O4" }
{ MUST-NOT-FIRE cases for the tzcnt/bsr bit-scan idiom. Each deliberately breaks
  one required condition; if the pass fired anyway it would compute a different
  value, so the asserted results double as proof the pass stays off. A false
  positive here is a miscompile. }
program bitscan_mustnotfire_01;
{$mode objfpc}

{ counter step is +2, not +1 -> result is 2*trailing-zeros, not tz }
function tz_step2(x: dword): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c, 2); x := x shr 1 end;
  tz_step2 := c;
end;

{ shifts by 2 each step -> counts pairs of trailing zeros, not tz }
function tz_shr2(x: dword): longint;
var c: longint;
begin
  c := 0;
  if (x and 1) = 0 then          { keep it finite for the values used below }
    while (x and 3) = 0 do begin inc(c); x := x shr 2 end;
  tz_shr2 := c;
end;

{ extra statement in the body -> not the two-statement shape }
function tz_extra(x: dword; var sink: longint): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); sink := sink + 1; x := x shr 1 end;
  tz_extra := c;
end;

{ bsr with a signed operand -> pass must skip (a negative x would be zero-trip
  yet Bsr would count its bits); for the positive values here it stays a loop
  and remains correct }
function bsr_signed(x: longint): longint;
var c: longint;
begin
  c := 0;
  while x > 1 do begin inc(c); x := x shr 1 end;
  bsr_signed := c;
end;

var
  sink: longint;
begin
  { $F0 = 1111_0000 -> 4 trailing zeros }
  if tz_step2($F0) <> 8 then Halt(1);          { 2*4, proves no tzcnt rewrite }
  if tz_shr2($F0) <> 2 then Halt(2);           { two shr-by-2 steps }
  sink := 0;
  if tz_extra($F0, sink) <> 4 then Halt(3);
  if sink <> 4 then Halt(4);                    { side effect preserved }
  if bsr_signed(1024) <> 10 then Halt(5);
  if bsr_signed(1) <> 0 then Halt(6);
  if bsr_signed(0) <> 0 then Halt(7);
end.
