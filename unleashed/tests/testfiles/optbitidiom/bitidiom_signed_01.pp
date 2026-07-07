{ %OPT="-O4" }
{ Signed operands: the loop clears the lowest set bit of the two's-complement
  bit pattern, so its trip count is the population count of that pattern. The
  rewrite reinterprets x as the same-width unsigned type before PopCnt, so a
  signed x (including negatives with the sign bit set) must give the same count
  as the scalar loop. -1 (all ones) is 32; longint(low($80000000)) is 1. }
program bitidiom_signed_01;
{$mode objfpc}

function popc(x: longint): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c);
      x := x and (x - 1);
    end;
  popc := c;
end;

function popc64(x: int64): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c);
      x := x and (x - 1);
    end;
  popc64 := c;
end;

begin
  if popc(0) <> 0 then Halt(1);
  if popc(-1) <> 32 then Halt(2);            { $FFFFFFFF }
  if popc(longint($80000000)) <> 1 then Halt(3);
  if popc(-2) <> 31 then Halt(4);            { $FFFFFFFE }
  if popc(255) <> 8 then Halt(5);

  if popc64(0) <> 0 then Halt(6);
  if popc64(-1) <> 64 then Halt(7);
  if popc64(int64($8000000000000000)) <> 1 then Halt(8);
end.
