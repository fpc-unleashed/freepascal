{ %OPT="-O4 -OoNOSINK" }
{ Control for optsink_correct_01: the identical logic compiled with code
  sinking DISABLED (-OoNOSINK).  Behaviour must be byte-for-byte identical to
  the enabled build -- same results for every input -- proving the transform
  changes only where a computation is emitted, never what it computes. }
program optsink_disabled_01;
{$mode objfpc}{$H+}

function onlythen(a, b, k: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b + 7;
  if guard then
    onlythen := d
  else
    onlythen := k;
end;

function onlyelse(a, b, k: longint; guard: boolean): longint; noinline;
var e: longint;
begin
  e := (a - b) * 3;
  if guard then
    onlyelse := k
  else
    onlyelse := e;
end;

function selfref(a: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a;
  d := d * d - 1;
  if guard then
    selfref := d
  else
    selfref := 0;
end;

function noelse(a, b: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b - a;
  noelse := 0;
  if guard then
    noelse := d;
end;

begin
  if onlythen(3, 4, 99, true)  <> 19  then Halt(1);
  if onlythen(3, 4, 99, false) <> 99  then Halt(2);
  if onlyelse(10, 4, 55, true) <> 55  then Halt(3);
  if onlyelse(10, 4, 55, false)<> 18  then Halt(4);
  if selfref(5, true)          <> 24  then Halt(5);
  if selfref(5, false)         <> 0   then Halt(6);
  if noelse(6, 7, true)        <> 36  then Halt(11);
  if noelse(6, 7, false)       <> 0   then Halt(12);
end.
