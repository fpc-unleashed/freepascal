{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE now accepts 64-bit loop counters. The symbolic trip count
  b-a+1 is computed in 64-bit two's-complement -- the true iteration count
  reduced mod 2^64 -- and every accumulator product is truncated to the
  accumulator's own width, so (count*c) mod 2^w is bit-identical to the
  repeated addition for any w<=64. Asserted against a directly-computed
  reference for int64 and qword counters, including near-boundary bounds where
  hi-lo+1 would not fit a signed int64 exactly, zero-trip loops, and downto. }
program fv_counter_64bit_01;
{$mode objfpc}{$H+}

{ int64 counter, int64 accumulator }
function accum_i64(a,b: int64): int64;
var i,s: int64;
begin
  s:=-1000;
  for i:=a to b do inc(s,7);
  accum_i64:=s;
end;

{ qword counter, int64 accumulator }
function accum_q64(a,b: qword): int64;
var i: qword; s: int64;
begin
  s:=0;
  for i:=a to b do inc(s,1);
  accum_q64:=s;
end;

{ int64 downto counter }
function accum_down(a,b: int64): int64;
var i,s: int64;
begin
  s:=500;
  for i:=a downto b do dec(s,3);
  accum_down:=s;
end;

var k: int64;
begin
  { ordinary + zero-trip ascending }
  for k:=0 to 200 do
    begin
      if accum_i64(1,k) <> -1000 + 7*k then Halt(1);      { max(0,k) iters }
      if accum_q64(1,k) <> k then Halt(2);
      { downto b=1: runs max(0, k-1+1)=max(0,k) iters }
      if accum_down(k,1) <> 500 - 3*k then Halt(3);
    end;
  { zero-trip (a>b ascending) leaves accumulator untouched }
  if accum_i64(10,9) <> -1000 then Halt(4);
  if accum_q64(10,9) <> 0 then Halt(5);
  if accum_down(0,1) <> 500 then Halt(6);                 { downto with a<b: zero-trip }

  { near the signed-64 boundary: hi-lo+1 stays exact mod 2^64, 4 iterations }
  if accum_i64(high(int64)-3, high(int64)) <> -1000 + 7*4 then Halt(7);
  { low boundary }
  if accum_i64(low(int64), low(int64)+2) <> -1000 + 7*3 then Halt(8);
  { qword near its top }
  if accum_q64(high(qword)-2, high(qword)) <> 3 then Halt(9);
  Halt(0);
end.
