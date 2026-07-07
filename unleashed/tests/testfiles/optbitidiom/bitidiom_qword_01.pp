{ %OPT="-O4" }
{ 64-bit variant of the population-count idiom (rewritten to PopCnt on qword).
  Covers 0, all-ones (64), the high bit, and alternating patterns. }
program bitidiom_qword_01;
{$mode objfpc}

function popc(x: qword): longint;
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
  if popc(qword($FFFFFFFFFFFFFFFF)) <> 64 then Halt(2);
  if popc(1) <> 1 then Halt(3);
  if popc(qword($8000000000000000)) <> 1 then Halt(4);
  if popc(qword($AAAAAAAAAAAAAAAA)) <> 32 then Halt(5);
  if popc(qword($00000000FFFFFFFF)) <> 32 then Halt(6);
  if popc(qword($FFFFFFFF00000000)) <> 32 then Halt(7);
end.
