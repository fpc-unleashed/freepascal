{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE must NOT transform (and must leave correct results for) loops it
  cannot prove sound: a body containing a break, a body with a live call/store,
  a global (non-local) accumulator, a loop whose counter's exit value is used
  afterwards, and a body doing more than one statement. All must still produce
  their normal counted-loop results. }
program fv_no_transform_01;
{$mode objfpc}{$H+}

var gs: longint;

{ break in body -> not a plain accumulator loop }
function with_break(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do begin inc(s,3); if i=3 then break; end;
  with_break:=s;
end;

{ global accumulator -> not a plain local }
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

var n: longint;
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
  Halt(0);
end.
