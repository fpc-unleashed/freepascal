{ %OPT="-O2 -OoSIBCALL" }
{ -OoSIBCALL result forwarding through more than one location: a 128-bit record
  result (rax:rdx) is staged through two rsp frame slots across the tail call,
  and a plain longint result is forwarded through a single callee-saved register.
  Both tail-call chains become jmps (frame reuse) so a large depth runs in O(1)
  stack and still returns the correct value. Results must match a plain call. }
program sibcall_forward128_01;
{$mode objfpc}{$H+}

type
  TPair = record a, b: int64; end;

{ 128-bit (rax:rdx) result forwarded through two frame slots }
function OddPair(n: longint): TPair; forward;

function EvenPair(n: longint): TPair;
var
  loc: array[0..3] of longint;
  i: longint;
begin
  for i := 0 to 3 do loc[i] := n + i;   { own frame }
  if n = 0 then
    begin EvenPair.a := 100 + loc[0]; EvenPair.b := 200 + loc[1]; end
  else
    EvenPair := OddPair(n - 1);
end;

function OddPair(n: longint): TPair;
var
  loc: array[0..3] of longint;
  i: longint;
begin
  for i := 0 to 3 do loc[i] := n - i;
  if n = 0 then
    begin OddPair.a := 300 + loc[0]; OddPair.b := 400 + loc[1]; end
  else
    OddPair := EvenPair(n - 1);
end;

{ single longint result forwarded through a callee-saved register (a value held
  live across the tail call forces the callee-saved reg + pop teardown shape) }
function Bounce(n: longint): longint; forward;

function Ping(n: longint): longint;
var
  a: array[0..7] of longint;
  i, keep: longint;
begin
  keep := n * 3 + 1;
  for i := 0 to 7 do a[i] := n + i;
  if n = 0 then Ping := keep + a[0]
  else Ping := Bounce(n - 1);
end;

function Bounce(n: longint): longint;
var
  a: array[0..7] of longint;
  i, keep: longint;
begin
  keep := n + 9;
  for i := 0 to 7 do a[i] := n - i;
  if n = 0 then Bounce := keep + a[0]
  else Bounce := Ping(n - 1);
end;

var
  p: TPair;
begin
  { deep chain: O(1) stack only if the tail calls are jmps }
  p := EvenPair(2000000);
  { even depth -> base is EvenPair(0): a=100+loc[0]=100, b=200+loc[1]=201 }
  if p.a <> 100 then Halt(1);
  if p.b <> 201 then Halt(2);

  p := EvenPair(1999999);
  { odd depth -> base is OddPair(0): a=300+loc[0]=300, b=400+loc[1]=400-1=399 }
  if p.a <> 300 then Halt(3);
  if p.b <> 399 then Halt(4);

  { single-register forward, deep: base is Ping(0): keep=1, a[0]=0 -> 1 }
  if Ping(2000000) <> 1 then Halt(5);
end.
