{ %OPT="-O4 -OoLOOPDISTPAT" }
{ Non-zero contiguous fills lower to FillChar/FillWord/FillDWord/FillQWord with
  the value reinterpreted to the matching unsigned width; both constant and
  loop-invariant-variable fill values must write the identical bytes the scalar
  store would. Signed/negative and truncating values are covered. }
program distpat_fill_value_01;
{$mode objfpc}{$H+}

procedure work(n: longint; bval: byte; wval: word; lval: longint; qval: int64);
var
  ab: array of byte;
  aw: array of word;
  al: array of longint;
  aq: array of int64;
  i: longint;
begin
  SetLength(ab,n); SetLength(aw,n); SetLength(al,n); SetLength(aq,n);
  { constant fills }
  for i:=0 to n-1 do ab[i]:=$AB;
  for i:=0 to n-1 do aw[i]:=$ABCD;
  for i:=0 to n-1 do al[i]:=longint($DEADBEEF);
  for i:=0 to n-1 do aq[i]:=int64($0102030405060708);
  for i:=0 to n-1 do begin
    if ab[i]<>$AB then Halt(1);
    if aw[i]<>$ABCD then Halt(2);
    if al[i]<>longint($DEADBEEF) then Halt(3);
    if aq[i]<>int64($0102030405060708) then Halt(4);
  end;
  { loop-invariant variable fills (params are loop-invariant) }
  for i:=0 to n-1 do ab[i]:=bval;
  for i:=0 to n-1 do aw[i]:=wval;
  for i:=0 to n-1 do al[i]:=lval;
  for i:=0 to n-1 do aq[i]:=qval;
  for i:=0 to n-1 do begin
    if ab[i]<>bval then Halt(5);
    if aw[i]<>wval then Halt(6);
    if al[i]<>lval then Halt(7);
    if aq[i]<>qval then Halt(8);
  end;
end;

var k: longint;
begin
  for k:=0 to 17 do work(k,17,4242,-123456789,-1);
  work(100,255,0,2147483647,int64($7FFFFFFFFFFFFFFF));
  work(777,1,65535,-1,1);
end.
