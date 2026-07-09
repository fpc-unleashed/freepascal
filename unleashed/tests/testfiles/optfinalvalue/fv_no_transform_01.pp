{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE must NOT transform (and must leave correct results for) loops it
  cannot prove sound: a body containing a break, a body with a live call/store,
  a loop whose counter's exit value is used afterwards, a body that updates the
  SAME accumulator twice (would be double-counted), and a pointer  p := p + stride
  assignment form (the stride is already element-size-scaled at this point). All
  must still produce their normal counted-loop results. (A global accumulator is
  now transformed -- see fv_global_accum_01 -- so global_acc below is retained as
  a correctness regression, not a non-transform case.) }
program fv_no_transform_01;
{$mode objfpc}{$H+}{$POINTERMATH ON}

type PLongint = ^Longint;

var gs: longint;

{ SAME accumulator updated twice per iteration -> not independent, would be
  double-counted by a per-statement closed form, so the pass must reject it }
function dup_acc(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do begin inc(s,3); inc(s,5); end;   { net +8 / iter }
  dup_acc:=s;
end;

{ pointer p := p + stride assignment form: after typecheck the stride is
  already element-size-scaled, so the pass deliberately rejects it (only the
  still-unlowered inc/dec pointer form is transformed) }
function ptr_assign(base: PLongint; n: longint): PtrInt;
var i: longint; p: PLongint;
begin
  p:=base;
  for i:=1 to n do p:=p+2;
  ptr_assign:=PtrInt(p)-PtrInt(base);
end;

{ break in body -> not a plain accumulator loop }
function with_break(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do begin inc(s,3); if i=3 then break; end;
  with_break:=s;
end;

{ global accumulator -> now transformed (see fv_global_accum_01); kept here as
  a correctness regression -- the closed form must give the same result }
function global_acc(n: longint): longint;
var i: longint;
begin
  gs:=0;
  for i:=1 to n do inc(gs,4);
  global_acc:=gs;
end;

{ counter used after the loop -> exit value is live, must not delete }
function counter_live(n: longint): longint;
var i,s: longint;
begin
  s:=0; i:=0;
  for i:=1 to n do inc(s,2);
  counter_live:=s*100 + i;   { i's final value observed }
end;

{ side effect (store to array) in body -> live side effect, keep loop }
function with_store(n: longint): longint;
var i,s: longint; a: array[0..63] of longint;
begin
  s:=0;
  for i:=1 to n do begin a[i and 63]:=i; inc(s,1); end;
  with_store:=s + a[n and 63];
end;

var n: longint; buf: array[0..64] of longint;
begin
  { break: stops after i=3 when n>=3 }
  if with_break(10) <> 9 then Halt(1);
  if with_break(2)  <> 6 then Halt(2);
  if global_acc(5)  <> 20 then Halt(3);
  if global_acc(0)  <> 0 then Halt(4);
  { counter_live: after for i:=1 to n, i = n (n>=1); s=2n }
  for n:=1 to 20 do
    if counter_live(n) <> (2*n)*100 + n then Halt(5);
  if with_store(10) <> 10 + 10 then Halt(6);
  for n:=0 to 20 do
    begin
      if dup_acc(n) <> 8*n then Halt(7);
      if ptr_assign(@buf[0], n) <> n*2*SizeOf(Longint) then Halt(8);
    end;
  Halt(0);
end.
