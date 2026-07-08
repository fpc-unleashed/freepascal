{ %OPT=-O4 }
{ Signed selectors with negative labels, ranges straddling zero, and holes.  The
  clustering must use signed dispatch compares (the case node picks jmp_lt/jmp_le
  from is_signed) and the bit-test rebase (unsigned(x-low)) must stay correct
  when low is negative.  Verified across the whole exercised domain including the
  holes between clusters and values below/above every label. }
program casecluster_signed_01;
{$mode objfpc}{$H+}

{ sparse negative single-target set -> bit-test with a negative low }
function fneg(x: shortint): integer;
begin
  case x of
    -30,-27,-24,-20,-15,-10: fneg:=1;
  else
    fneg:=0;
  end;
end;
function rneg(x: shortint): integer;
begin
  if (x=-30) or (x=-27) or (x=-24) or (x=-20) or (x=-15) or (x=-10) then rneg:=1 else rneg:=0;
end;

{ mix of negative ranges, a dense run around zero and a positive straggler }
function fmix(x: longint): longint;
begin
  case x of
    -100..-95: fmix:=1;      { negative range }
    -5..5: fmix:=2;          { dense run across zero -> jump table }
    -40,-38,-36,-34,-32: fmix:=3;  { sparse negative bit-test }
    77: fmix:=4;
  else
    fmix:=-1;
  end;
end;
function rmix(x: longint): longint;
begin
  if (x>=-100) and (x<=-95) then rmix:=1
  else if (x>=-5) and (x<=5) then rmix:=2
  else if (x=-40) or (x=-38) or (x=-36) or (x=-34) or (x=-32) then rmix:=3
  else if x=77 then rmix:=4
  else rmix:=-1;
end;

var i: longint;
begin
  for i:=-128 to 127 do
    if fneg(shortint(i))<>rneg(shortint(i)) then Halt(1);
  for i:=-150 to 150 do
    if fmix(i)<>rmix(i) then Halt(2);
  if fmix(low(longint))<>rmix(low(longint)) then Halt(3);
  if fmix(high(longint))<>rmix(high(longint)) then Halt(4);
  Writeln('OK');
  Halt(0);
end.
