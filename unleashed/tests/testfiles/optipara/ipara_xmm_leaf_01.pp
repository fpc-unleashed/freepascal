{ %OPT="-O2 -OoIPARA" }
{ -OoIPARA tracks XMM/MM clobbers as well as integer ones: a caller keeps many
  double values live across calls to small floating leaves (results returned in
  XMM0). The leaves clobber only a couple of XMM registers, so the caller's live
  doubles stay in untouched volatile XMM registers rather than being spilled. A
  wrong XMM clobber set would corrupt a live double; the exact-arithmetic checks
  below (all values representable) catch that. }
program ipara_xmm_leaf_01;
{$mode objfpc}

function dadd(a,b: double): double;
begin dadd:=a+b; end;

function dmul(a,b: double): double;
begin dmul:=a*b; end;

function daxpy(a,x,y: double): double;
begin daxpy:=a*x+y; end;

function hot(a,b,c,d,e: double): double;
var s: double;
begin
  s:=dadd(a,b);
  s:=s+dmul(c,d);
  s:=s+daxpy(a,b,c);
  s:=s+a+b+c+d+e;
  hot:=s;
end;

var r: double; acc: double; i: longint;
begin
  { dadd(1,2)=3; dmul(3,4)=12; daxpy(1,2,3)=5; +1+2+3+4+5=15 => 3+12+5+15=35 }
  r:=hot(1,2,3,4,5);
  if r<>35.0 then Halt(1);
  { mix integer and xmm live values through a loop }
  acc:=0;
  for i:=1 to 50 do
    acc:=acc+daxpy(2,i,1)+dadd(i,i)-dmul(i,1);
  { daxpy(2,i,1)=2i+1; dadd=2i; dmul=i; total per i = 2i+1+2i-i=3i+1
    sum_{1..50}(3i+1)=3*1275+50=3875 }
  if acc<>3875.0 then Halt(2);
end.
