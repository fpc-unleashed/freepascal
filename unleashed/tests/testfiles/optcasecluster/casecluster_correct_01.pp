{ %OPT=-O4 }
{ gcc-style case clustering (-O4 -OoCASECLUSTER) partitions the sorted case
  labels into a mix of jump-table / bit-test / plain-compare clusters dispatched
  by a balanced comparison tree.  Whatever the lowering, the observable result
  must be IDENTICAL to a straight if/else reference for EVERY value of the
  selector -- inside clusters, in the holes between labels, on the range
  boundaries and off both ends.  Each case function below is exercised over its
  entire ordinal domain and compared against an independently written reference
  (plain comparisons, unaffected by case lowering).  A mismatch halts with a
  distinct code identifying the shape. }
program casecluster_correct_01;
{$mode objfpc}{$H+}

{ vowel shape -> sparse single-target bit-test cluster }
function fvowel(c: char): integer;
begin
  case c of
    'a','e','i','o','u': fvowel:=1;
  else
    fvowel:=0;
  end;
end;
function rvowel(c: char): integer;
begin
  if (c='a') or (c='e') or (c='i') or (c='o') or (c='u') then rvowel:=1 else rvowel:=0;
end;

{ classifier: a dense digit run (jump table), a sparse vowel bit-test, a
  whitespace bit-test and a couple of stragglers -> several clusters }
function fclass(c: char): integer;
begin
  case c of
    '0'..'9': fclass:=2;
    'a','e','i','o','u': fclass:=1;
    ' ',#9,#10,#13: fclass:=3;
    '+','-','*','/': fclass:=4;
    'A'..'F': fclass:=5;
  else
    fclass:=0;
  end;
end;
function rclass(c: char): integer;
begin
  if (c>='0') and (c<='9') then rclass:=2
  else if (c='a') or (c='e') or (c='i') or (c='o') or (c='u') then rclass:=1
  else if (c=' ') or (c=#9) or (c=#10) or (c=#13) then rclass:=3
  else if (c='+') or (c='-') or (c='*') or (c='/') then rclass:=4
  else if (c>='A') and (c<='F') then rclass:=5
  else rclass:=0;
end;

{ mixed sparse + dense over a wide integer domain with ranges and holes }
function fmix(x: longint): longint;
begin
  case x of
    0..7: fmix:=10;          { dense run -> jump table }
    100,102,104,106,108: fmix:=20;   { sparse even -> bit test }
    200..201: fmix:=30;      { small range }
    500: fmix:=40;           { lone value }
    1000..1003: fmix:=50;    { another dense run }
  else
    fmix:=-1;
  end;
end;
function rmix(x: longint): longint;
begin
  if (x>=0) and (x<=7) then rmix:=10
  else if (x=100) or (x=102) or (x=104) or (x=106) or (x=108) then rmix:=20
  else if (x>=200) and (x<=201) then rmix:=30
  else if x=500 then rmix:=40
  else if (x>=1000) and (x<=1003) then rmix:=50
  else rmix:=-1;
end;

var
  i: longint;
  c: char;
begin
  { full char domain for the char-selector cases }
  for i:=0 to 255 do
    begin
      c:=chr(i);
      if fvowel(c)<>rvowel(c) then Halt(1);
      if fclass(c)<>rclass(c) then Halt(2);
    end;

  { wide integer domain: cover every cluster, every hole, both ends }
  for i:=-50 to 1100 do
    if fmix(i)<>rmix(i) then Halt(3);
  { boundary / far-out values }
  if fmix(low(longint))<>rmix(low(longint)) then Halt(4);
  if fmix(high(longint))<>rmix(high(longint)) then Halt(5);
  if fmix(999)<>rmix(999) then Halt(6);
  if fmix(1004)<>rmix(1004) then Halt(7);
  if fmix(101)<>rmix(101) then Halt(8);   { hole inside the sparse bit-test span }

  Writeln('OK');
  Halt(0);
end.
