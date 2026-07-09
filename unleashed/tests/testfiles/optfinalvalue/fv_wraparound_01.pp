{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE preserves two's-complement wraparound: without overflow/range
  checking, s0 + iters*c (mod 2^width) equals the repeated addition, so the
  closed form must be bit-identical even when the accumulator overflows its
  byte/word/shortint type. Checked against a masked reference for trip counts
  0..300 (enough to wrap byte and word accumulators several times). }
program fv_wraparound_01;
{$mode objfpc}{$H+}

function acc_byte(n: longint): byte;
var i: longint; s: byte;
begin
  s:=200;
  for i:=1 to n do inc(s,5);
  acc_byte:=s;
end;

function acc_word(n: longint): word;
var i: longint; s: word;
begin
  s:=60000;
  for i:=1 to n do s:=s+1000;
  acc_word:=s;
end;

function acc_shortint(n: longint): shortint;
var i: longint; s: shortint;
begin
  s:=100;
  for i:=1 to n do dec(s,7);
  acc_shortint:=s;
end;

var
  n: longint;
  rb: longint;
begin
  for n:=0 to 300 do
    begin
      if acc_byte(n) <> byte((200 + 5*n) and $FF) then Halt(1);
      if acc_word(n) <> word((60000 + 1000*n) and $FFFF) then Halt(2);
      rb:=(100 - 7*n) and $FF;
      if acc_shortint(n) <> shortint(rb) then Halt(3);
    end;
  Halt(0);
end.
