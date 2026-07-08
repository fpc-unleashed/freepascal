{ %OPT="-O4 -OoLOOPDISTPAT" }
{ The motivating shape: a class with a dynamic-array field (like neural-api's
  TNNetVolume.FData) cleared and copied element-by-element. The destination base
  is a side-effect-free, counter-independent l-value (Self.FData), so the fill
  and copy still lower to FillChar/Move even though the base is a field access,
  not a plain variable. }
program distpat_field_01;
{$mode objfpc}{$H+}
type
  TVolume = class
    FData: array of single;
    procedure Resize(n: longint);
    procedure Clear;
    procedure CopyFrom(src: TVolume);
    procedure Fill(v: single);
    function Sum: double;
  end;

procedure TVolume.Resize(n: longint); begin SetLength(FData,n); end;

procedure TVolume.Clear;
var i: longint;
begin
  for i:=0 to High(FData) do FData[i]:=0;
end;

procedure TVolume.CopyFrom(src: TVolume);
var i: longint;
begin
  for i:=0 to High(FData) do FData[i]:=src.FData[i];
end;

procedure TVolume.Fill(v: single);
var i: longint;
begin
  { non-zero float fill is NOT lowered, but must still be correct }
  for i:=0 to High(FData) do FData[i]:=v;
end;

function TVolume.Sum: double;
var i: longint;
begin
  Result:=0;
  for i:=0 to High(FData) do Result:=Result+FData[i];
end;

procedure work(n: longint);
var a,b: TVolume; i: longint; expect: double;
begin
  a:=TVolume.Create; b:=TVolume.Create;
  a.Resize(n); b.Resize(n);
  a.Fill(2.0);
  a.Clear;
  if a.Sum<>0.0 then Halt(1);
  for i:=0 to n-1 do b.FData[i]:=i*0.25-1.0;
  a.CopyFrom(b);
  expect:=b.Sum;
  if a.Sum<>expect then Halt(2);
  for i:=0 to n-1 do if a.FData[i]<>b.FData[i] then Halt(3);
  a.Free; b.Free;
end;

var k: longint;
begin
  for k:=0 to 9 do work(k);
  work(257);
  work(4096);
end.
