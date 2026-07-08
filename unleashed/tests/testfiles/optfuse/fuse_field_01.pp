{ %OPT="-O4 -OoLOOPFUSE -vn" }
{ The neural-api TNNetVolume shape: two adjacent element-wise passes over a
  field-backed dynamic array (Self.FData[i]) -- a bias/scale add immediately
  followed by a ReLU activation -- must fuse and stay correct. The ReLU is
  written as  if FData[i]<0 then FData[i]:=0 , which FPC's if-conversion turns
  into FData[i]:=Max(FData[i],0) (an in_max_* intrinsic the fusion whitelist
  admits). Bounds use High(FData), whose value is unchanged by element stores. }
program fuse_field_01;
{$mode objfpc}{$H+}

type
  TVol = class
    FData: array of single;
    constructor Create(n: longint);
    procedure biasScaleRelu(scale, bias: single);
    function checksum: double;
  end;

constructor TVol.Create(n: longint);
var i: longint;
begin
  SetLength(FData,n);
  for i:=0 to n-1 do FData[i]:=(i mod 61)-30.0;
end;

procedure TVol.biasScaleRelu(scale, bias: single);
var i: longint;
begin
  for i:=0 to High(FData) do FData[i]:=FData[i]*scale + bias;   { loop 1 }
  for i:=0 to High(FData) do if FData[i]<0.0 then FData[i]:=0.0;{ loop 2 (ReLU) }
end;

function TVol.checksum: double;
var i: longint;
begin
  checksum:=0;
  for i:=0 to High(FData) do checksum:=checksum+FData[i];
end;

{ same computation with the two passes forced non-adjacent (a barrier between),
  so it is NOT fused -- the reference result. }
function ref(n: longint; scale,bias: single): double;
var d: array of single; i,barrier: longint; acc: double;
begin
  SetLength(d,n);
  for i:=0 to n-1 do d[i]:=(i mod 61)-30.0;
  barrier:=0;
  for i:=0 to n-1 do d[i]:=d[i]*scale + bias;
  inc(barrier);
  for i:=0 to n-1 do if d[i]<0.0 then d[i]:=0.0;
  acc:=0;
  for i:=0 to n-1 do acc:=acc+d[i];
  ref:=acc+barrier-barrier;
end;

var
  v: TVol;
  n: longint;
begin
  for n:=0 to 40 do
    begin
      v:=TVol.Create(n);
      v.biasScaleRelu(1.5,-4.0);
      if Abs(v.checksum-ref(n,1.5,-4.0))>1e-2 then Halt(1);
      v.Free;
    end;
end.
