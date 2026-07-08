{ %OPT="-O4" }
{ Code sinking (-OoSINK, on at -O4).  A pure assignment  V:=<expr>  that
  precedes an if and whose value is consumed on only ONE arm is moved into that
  arm.  Sinking is a pure relocation: it must never change any result, only
  where the work is done.  Every function below exercises a shape the pass
  either sinks (then-arm, else-arm, self-reference, chained) or must leave alone
  (used on both arms, used after the if), and asserts the value is correct.
  Halts with the check number on any mismatch. }
program optsink_correct_01;
{$mode objfpc}{$H+}

{ value used only in the THEN arm -> sinkable }
function onlythen(a, b, k: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b + 7;
  if guard then
    onlythen := d
  else
    onlythen := k;
end;

{ value used only in the ELSE arm -> sinkable into the else branch }
function onlyelse(a, b, k: longint; guard: boolean): longint; noinline;
var e: longint;
begin
  e := (a - b) * 3;
  if guard then
    onlyelse := k
  else
    onlyelse := e;
end;

{ RHS reads the target itself (V:=V+..); the pre-if value feeds the move,
  which is exactly what the original then-arm read too -> still correct }
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

{ value used on BOTH arms -> must NOT be sunk, but the result stays correct }
function botharms(a, b: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b;
  if guard then
    botharms := d + 1
  else
    botharms := d - 1;
end;

{ value used AFTER the if (live on the fall-through) -> must NOT be sunk }
function liveafter(a, b: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b;
  if guard then
    exit(100);
  liveafter := d + 5;
end;

{ no else arm: on the false path the sunk work is skipped entirely }
function noelse(a, b: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * b - a;
  noelse := 0;
  if guard then
    noelse := d;
end;

begin
  if onlythen(3, 4, 99, true)  <> 19  then Halt(1);   { 3*4+7 }
  if onlythen(3, 4, 99, false) <> 99  then Halt(2);
  if onlyelse(10, 4, 55, true) <> 55  then Halt(3);
  if onlyelse(10, 4, 55, false)<> 18  then Halt(4);   { (10-4)*3 }
  if selfref(5, true)          <> 24  then Halt(5);   { 5*5-1 }
  if selfref(5, false)         <> 0   then Halt(6);
  if botharms(6, 7, true)      <> 43  then Halt(7);   { 42+1 }
  if botharms(6, 7, false)     <> 41  then Halt(8);   { 42-1 }
  if liveafter(6, 7, true)     <> 100 then Halt(9);
  if liveafter(6, 7, false)    <> 47  then Halt(10);  { 42+5 }
  if noelse(6, 7, true)        <> 36  then Halt(11);  { 42-6 }
  if noelse(6, 7, false)       <> 0   then Halt(12);
end.
