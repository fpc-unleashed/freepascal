{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE final value replacement: an ascending counted loop whose body
  is a single accumulator update  inc(s,c) / s:=s+c  is replaced by the closed
  form  if a<=b then s:=s+(b-a+1)*c  and the loop deleted. Asserted bit-exact
  against a directly-computed reference (independent arithmetic, not a loop) for
  every trip count 0..40, exercising the non-zero and zero-trip (a>b) cases. }
program fv_accum_up_01;
{$mode objfpc}{$H+}

function accum_inc(n: longint): longint;
var i,s: longint;
begin
  s:=17;
  for i:=1 to n do inc(s,3);
  accum_inc:=s;
end;

function accum_add(n: longint): longint;
var i,s: longint;
begin
  s:=-4;
  for i:=1 to n do s:=s+5;
  accum_add:=s;
end;

{ variable bounds -> may be zero-trip when a>b }
function accum_bounds(a,b: longint): longint;
var i,s: longint;
begin
  s:=1000;
  for i:=a to b do inc(s,2);
  accum_bounds:=s;
end;

var
  n: longint;
  iters: longint;
begin
  for n:=0 to 40 do
    begin
      if n<0 then iters:=0 else iters:=n;   { for i:=1 to n runs max(0,n) times }
      if accum_inc(n) <> 17 + 3*iters then Halt(1);
      if accum_add(n) <> -4 + 5*iters then Halt(2);
      { a=5,b=n : runs max(0, n-5+1) times }
      if n>=5 then
        begin if accum_bounds(5,n) <> 1000 + 2*(n-5+1) then Halt(3); end
      else
        begin if accum_bounds(5,n) <> 1000 then Halt(4); end;   { zero-trip }
    end;
  Halt(0);
end.
