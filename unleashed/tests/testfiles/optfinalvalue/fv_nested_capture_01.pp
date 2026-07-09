{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE must NOT delete a loop whose counter or accumulator is captured
  by a nested procedure (accessed from a different scope) or has its address
  taken: the whole-routine dead-counter / single-update scan cannot see uses
  inside the nested routine or through a pointer, so such vars are rejected and
  the loop is kept. Results must stay correct. }
program fv_nested_capture_01;
{$mode objfpc}{$H+}

{ accumulator s captured by a nested proc }
function captured_acc(n: longint): longint;
var i,s: longint;
  procedure bump; begin inc(s); end;
begin
  s:=0;
  for i:=1 to n do inc(s,2);
  bump;
  captured_acc:=s;
end;

{ counter i captured by a nested proc that reads it after the loop }
function captured_ctr(n: longint): longint;
var i,s: longint;
  function peek: longint; begin peek:=i; end;
begin
  s:=0;
  for i:=1 to n do inc(s,3);
  captured_ctr:=s + peek;   { observes i's exit value via nested scope }
end;

{ accumulator whose address is taken (aliased) }
procedure addone(var x: longint); begin x:=x+1; end;
function addr_acc(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do inc(s,4);
  addone(s);
  addr_acc:=s;
end;

var n: longint;
begin
  for n:=1 to 20 do
    begin
      if captured_acc(n) <> 2*n + 1 then Halt(1);
      { after the loop i=n (n>=1); result = 3n + n }
      if captured_ctr(n) <> 3*n + n then Halt(2);
      if addr_acc(n) <> 4*n + 1 then Halt(3);
    end;
  Halt(0);
end.
