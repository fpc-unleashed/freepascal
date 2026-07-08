{ %OPT="-O4 -OoLOOPDISTPAT" }
{ Contiguous zero-fill of a dynamic array over every unmanaged element width
  lowers to FillChar; result must be all-zero for trip counts 0,1,odd,even and
  a large run. The counter is a local so the pass fires. }
program distpat_fill_zero_01;
{$mode objfpc}{$H+}
type
  TEnum = (eA,eB,eC,eD);

procedure work(n: longint);
var
  ab: array of byte;
  aw: array of word;
  al: array of longint;
  aq: array of int64;
  asf: array of single;
  adf: array of double;
  ap: array of pointer;
  ae: array of TEnum;
  i: longint;
begin
  SetLength(ab,n); SetLength(aw,n); SetLength(al,n); SetLength(aq,n);
  SetLength(asf,n); SetLength(adf,n); SetLength(ap,n); SetLength(ae,n);
  { dirty every element first }
  for i:=0 to n-1 do begin
    ab[i]:=255; aw[i]:=65535; al[i]:=-1; aq[i]:=-1;
    asf[i]:=3.5; adf[i]:=-2.5; ap[i]:=@i; ae[i]:=eD;
  end;
  { the lowered zero-fills }
  for i:=0 to n-1 do ab[i]:=0;
  for i:=0 to n-1 do aw[i]:=0;
  for i:=0 to n-1 do al[i]:=0;
  for i:=0 to n-1 do aq[i]:=0;
  for i:=0 to n-1 do asf[i]:=0;
  for i:=0 to n-1 do adf[i]:=0;
  for i:=0 to n-1 do ap[i]:=nil;
  for i:=0 to n-1 do ae[i]:=eA;
  { verify }
  for i:=0 to n-1 do begin
    if ab[i]<>0 then Halt(1);
    if aw[i]<>0 then Halt(2);
    if al[i]<>0 then Halt(3);
    if aq[i]<>0 then Halt(4);
    if asf[i]<>0.0 then Halt(5);
    if adf[i]<>0.0 then Halt(6);
    if ap[i]<>nil then Halt(7);
    if ae[i]<>eA then Halt(8);
  end;
end;

var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100);
  work(1000);
end.
