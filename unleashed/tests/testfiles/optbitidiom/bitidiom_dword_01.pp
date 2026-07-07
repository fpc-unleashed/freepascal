{ %OPT="-O4" }
{ Bit-population-count idiom: the canonical clear-lowest-set-bit loop over a
  dword is rewritten to PopCnt at -O4 (-OoBITIDIOM). This checks the rewrite is
  value-identical to the scalar loop across edge cases: 0, all-ones, a single
  low/high bit, alternating bits and an ordinary value. Runs correctly whether
  or not the pass fires. }
program bitidiom_dword_01;
{$mode objfpc}

function popc(x: dword): longint;
var
  c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      inc(c);
      x := x and (x - 1);
    end;
  popc := c;
end;

begin
  if popc(0) <> 0 then Halt(1);
  if popc($FFFFFFFF) <> 32 then Halt(2);
  if popc(1) <> 1 then Halt(3);
  if popc($80000000) <> 1 then Halt(4);
  if popc($AAAAAAAA) <> 16 then Halt(5);
  if popc($55555555) <> 16 then Halt(6);
  if popc($F0F0F0F0) <> 16 then Halt(7);
  if popc(7) <> 3 then Halt(8);
  if popc(42) <> 3 then Halt(9);
end.
