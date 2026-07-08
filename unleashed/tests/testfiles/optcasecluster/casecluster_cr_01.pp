{ %OPT="-O4 -Cr -Co" }
{ Clustering under range- and overflow-checking.  The bit-test rebase does an
  unsigned(x-low) subtraction and the jump-table cluster indexes a table; neither
  may trip a spurious range/overflow error for in-domain selector values, and
  holes must still reach the else arm.  Runs with -Cr/-Co active over selector
  values that hit every cluster, the holes between them, and the exact domain
  bounds of each selector type.  Must complete without a range-check error and
  match the reference. }
program casecluster_cr_01;
{$mode objfpc}{$H+}

function fb(b: byte): longint;
begin
  case b of
    10,12,14,16,18,20: fb:=1;   { sparse -> bit test }
    100..120: fb:=2;            { dense -> jump table }
    200,255: fb:=3;
  else fb:=0;
  end;
end;
function rb(b: byte): longint;
begin
  if (b=10) or (b=12) or (b=14) or (b=16) or (b=18) or (b=20) then rb:=1
  else if (b>=100) and (b<=120) then rb:=2
  else if (b=200) or (b=255) then rb:=3
  else rb:=0;
end;

var i: longint;
begin
  for i:=0 to 255 do
    if fb(byte(i))<>rb(byte(i)) then Halt(1);
  Writeln('OK');
  Halt(0);
end.
