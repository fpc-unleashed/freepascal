{ %OPT="-O2 -Cr -OoFINALVALUE" }
{ Under range checking (-Cr, without -Co) -OoFINALVALUE stays enabled, but
  restricted to native full-range integer accumulators (int64/qword): their
  s:=s+c performs no narrowing conversion, so -Cr inserts no range check and
  the wrap-around closed form matches the loop bit-for-bit. A sub-native
  accumulator (longint/byte/...) WOULD be range-checked on its narrowing store,
  so the pass declines it and the checked loop runs unchanged.

  This test compiles under -Cr and asserts correct results for both the
  transformed (native) and the still-looping (sub-native) accumulators,
  including int64 wraparound (which -Cr does not fault on) and zero-trip loops.
  A spurious range fault -- or a wrong value -- would abort with error 201 or a
  failed Halt. }
program fv_rangecheck_native_01;
{$mode objfpc}{$H+}

{ native int64 accumulator -> transformed under -Cr }
function nat_i64(n: longint): int64;
var i: longint; s: int64;
begin
  s:=high(int64)-10;
  for i:=1 to n do inc(s,3);        { wraps past high(int64); -Cr does not fault }
  nat_i64:=s;
end;

{ native qword accumulator -> transformed under -Cr }
function nat_q64(n: longint): qword;
var i: longint; s: qword;
begin
  s:=1000;
  for i:=1 to n do inc(s,4);
  nat_q64:=s;
end;

{ sub-native longint accumulator -> NOT transformed under -Cr (declined);
  values kept well within longint range so the checked loop does not fault }
function sub_l32(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do inc(s,2);
  sub_l32:=s;
end;

var n: longint;
begin
  for n:=0 to 200 do
    begin
      if nat_i64(n) <> int64(high(int64)-10) + 3*n then Halt(1);   { two's-compl wrap }
      if nat_q64(n) <> qword(1000 + 4*n) then Halt(2);
      if sub_l32(n) <> 2*n then Halt(3);
    end;
  { zero-trip leaves accumulators unchanged }
  if nat_i64(0) <> high(int64)-10 then Halt(4);
  if nat_q64(0) <> 1000 then Halt(5);
  Halt(0);
end.
