{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE now accepts a unit-level / global (static) variable as an
  accumulator (never as the loop counter). It is sound because the loop body
  has no calls and the routine no exception paths, so nothing observes the
  global's intermediate states cross-routine within this thread; the closed
  form stores the identical final value -- the same reason the optimizer may
  already keep such an accumulator in a register across the loop.

  Asserted against a directly-computed reference for global int64 and qword
  accumulators (add and subtract), a mixed local+global body, and zero-trip
  loops. A threadvar or address-taken global stays rejected (not exercised for
  a value here, only that ordinary globals give the right answer). }
program fv_global_accum_01;
{$mode objfpc}{$H+}

var
  gi: int64;
  gq: qword;
  gj: int64;

function gadd(n: longint): int64;
var i: longint;
begin
  gi:=250;
  for i:=1 to n do inc(gi,6);
  gadd:=gi;
end;

function gsub(n: longint): qword;
var i: longint;
begin
  gq:=100000;
  for i:=1 to n do dec(gq,5);
  gsub:=gq;
end;

{ mixed body: one local and one global accumulator, both closed-formed }
function gmix(n: longint): int64;
var i: longint; ls: int64;
begin
  ls:=0; gj:=1;
  for i:=1 to n do begin inc(ls,2); inc(gj,3); end;
  gmix:=ls*1000 + gj;
end;

var n: longint;
begin
  for n:=0 to 200 do
    begin
      if gadd(n) <> 250 + 6*n then Halt(1);
      if gsub(n) <> qword(100000 - 5*n) then Halt(2);
      if gmix(n) <> (2*n)*1000 + (1 + 3*n) then Halt(3);
    end;
  { zero-trip: globals keep their pre-loop value }
  if gadd(0) <> 250 then Halt(4);
  if gsub(0) <> 100000 then Halt(5);
  Halt(0);
end.
