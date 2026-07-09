{ %OPT="-O2 -OoIPARA" }
{ -OoIPARA (interprocedural register allocation): a caller keeps many independent
  integer values live across repeated calls to small leaf helpers. With the full
  ABI mask these would be evacuated to callee-saved registers; -OoIPARA keeps
  them in the volatile registers the leaves provably never touch. A wrong (too
  small) clobber set would corrupt one of the live values, so the arithmetic
  identities below are a direct correctness check. Result registers (RAX) are
  exercised on every call. }
program ipara_int_leaf_01;
{$mode objfpc}

function addone(x: longint): longint;
begin addone:=x+1; end;

function twice(x: longint): longint;
begin twice:=x+x; end;

function combine(a,b,c: longint): longint;
begin combine:=a-b+c; end;

function hot(a,b,c,d,e,f: longint): longint;
var s: longint;
begin
  { many values live across the calls }
  s:=addone(a);
  s:=s+twice(b);
  s:=s+combine(c,d,e);
  { every original parameter must have survived the calls unchanged }
  s:=s+a+b+c+d+e+f;
  hot:=s;
end;

var r: longint; i: longint;
begin
  { addone(1)=2; twice(2)=4; combine(3,4,5)=4; +1+2+3+4+5+6=21 => 2+4+4+21=31 }
  r:=hot(1,2,3,4,5,6);
  if r<>31 then Halt(1);
  r:=hot(10,20,30,40,50,60);
  { 11 + 40 + (30-40+50=40) + (10+20+30+40+50+60=210) = 301 }
  if r<>301 then Halt(2);
  { drive a loop so a hot value is repeatedly live across the call }
  r:=0;
  for i:=1 to 100 do
    r:=r+addone(i)+twice(i)-combine(i,i,i);
  { addone(i)+2i-(i-i+i)= (i+1)+2i-i = 2i+1; sum_{1..100}(2i+1)=2*5050+100=10200 }
  if r<>10200 then Halt(3);
end.
