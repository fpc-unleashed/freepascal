{ %OPT="-O2 -OoIPARA" }
{ -OoIPARA must stay correct in every fallback situation, all mixed with the
  optimizable direct-call case:
    - a callee that itself calls an unknown (external RTL) routine => the whole
      volatile mask flows into its recorded clobber set, so callers get no
      (unsafe) reduction;
    - an indirect call through a procedure variable => full mask, untouched;
    - a virtual method dispatch => full mask, untouched;
    - a caller with try/except around a call whose live value re-enters the
      handler => the reduction is disabled for that whole routine, because an
      exception unwind restores only callee-saved registers.
  Every result is checked against its expected value. }
program ipara_fallbacks_01;
{$mode objfpc}
uses SysUtils;

type
  tfn = function(x,y: longint): longint;

  tbase = class
    function calc(x: longint): longint; virtual;
  end;
  tderived = class(tbase)
    function calc(x: longint): longint; override;
  end;

function tbase.calc(x: longint): longint;   begin calc:=x+1; end;
function tderived.calc(x: longint): longint; begin calc:=x*2; end;

function iadd(x,y: longint): longint;
begin iadd:=x+y; end;

{ callee that calls an unknown target (IntToStr) -> full clobber mask recorded }
function withio(x: longint): longint;
begin withio:=x+Length(IntToStr(x)); end;

{ caller of the unknown-calling helper, keeping many live values }
function callsio(a,b,c: longint): longint;
var s: longint;
begin
  s:=withio(a);
  s:=s+b+c+a;
  callsio:=s;
end;

{ indirect call through a procvar }
function viaptr(p: tfn; a,b: longint): longint;
var k: longint;
begin
  k:=a*3;
  k:=k+p(a,b);
  viaptr:=k+a+b;
end;

{ virtual dispatch }
function viavirt(o: tbase; a: longint): longint;
var k: longint;
begin
  k:=a*4;
  k:=k+o.calc(a);
  viavirt:=k+a;
end;

{ caller with exception handling; a live value re-enters the handler }
function withexc(a,b: longint): longint;
var k: longint;
begin
  k:=a*5;
  try
    k:=k+iadd(a,b);
    if b=0 then raise Exception.Create('boom');
    k:=k+1;
  except
    k:=k+a;      { a must be intact in the handler }
  end;
  withexc:=k+a+b;
end;

var
  o: tbase; dvd: tderived;
begin
  { withio(2)=2+len("2")=3; +3+4+2=9 => 12 }
  if callsio(2,3,4)<>12 then Halt(1);
  { viaptr(@iadd,7,9): 21 + 16 + 7 + 9 = 53 }
  if viaptr(@iadd,7,9)<>53 then Halt(2);

  o:=tbase.Create;
  { viavirt(base,5): 20 + 6 + 5 = 31 }
  if viavirt(o,5)<>31 then Halt(3);
  o.Free;

  dvd:=tderived.Create;
  { viavirt(derived,5): 20 + 10 + 5 = 35 }
  if viavirt(dvd,5)<>35 then Halt(4);
  dvd.Free;

  { withexc(3,4): k=15; +iadd(3,4)=22; +1=23; +3+4 => 30 }
  if withexc(3,4)<>30 then Halt(5);
  { withexc(3,0): k=15; +iadd=18; raise; handler +3=21; +3+0 => 24 }
  if withexc(3,0)<>24 then Halt(6);
end.
