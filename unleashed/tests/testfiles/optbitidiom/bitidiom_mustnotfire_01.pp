{ %OPT="-O4" }
{ MUST-NOT-FIRE cases. Each is deliberately NOT the population-count idiom; if
  the pass fired anyway it would compute a different answer, so the asserted
  results double as proof the pass stays off. A false positive here is a
  miscompile. }
program bitidiom_mustnotfire_01;
{$mode objfpc}

{ step is +2, not +1 -> must stay a loop (result is 2*popcount) }
function step2(x: dword): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c, 2);
      x := x and (x - 1);
    end;
  step2 := c;
end;

{ an extra statement in the body -> not the two-statement shape }
function extra_stmt(x: dword; var sink: longint): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c);
      sink := sink + 1;         { extra observable side effect }
      x := x and (x - 1);
    end;
  extra_stmt := c;
end;

{ repeat..until runs the body once even for x=0 -> count(0) must be 1, which
  PopCnt(0)=0 would get wrong; the pass rejects repeat..until }
function rep(x: dword): longint;
var c: longint;
begin
  c := 0;
  repeat
    inc(c);
    x := x and (x - 1);
  until x = 0;
  rep := c;
end;

{ the step is  x := x shr 1 , not  x and (x-1)  -> this counts the bit LENGTH
  (highest set bit position), not the population count. Must not be rewritten
  to PopCnt. }
function bitlen(x: dword): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c);
      x := x shr 1;
    end;
  bitlen := c;
end;

var
  sink: longint;
begin
  { step2 = 2 * popcount }
  if step2($FFFFFFFF) <> 64 then Halt(1);
  if step2($AAAAAAAA) <> 32 then Halt(2);
  if step2(0) <> 0 then Halt(3);

  { extra statement: sink must be bumped once per set bit }
  sink := 0;
  if extra_stmt($F0F0F0F0, sink) <> 16 then Halt(4);
  if sink <> 16 then Halt(5);

  { repeat..until: body runs at least once }
  if rep(0) <> 1 then Halt(6);
  if rep($FFFFFFFF) <> 32 then Halt(7);
  if rep(1) <> 1 then Halt(8);

  { bit length, not popcount }
  if bitlen(0) <> 0 then Halt(9);
  if bitlen(1) <> 1 then Halt(10);
  if bitlen($80000000) <> 32 then Halt(11);
  if bitlen(255) <> 8 then Halt(12);
  if bitlen($FFFFFFFF) <> 32 then Halt(13);
end.
