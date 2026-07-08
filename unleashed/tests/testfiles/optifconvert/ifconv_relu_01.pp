{ %OPT="-O4 -Cfsse64" }
{ If-conversion (-O4 -OoIFCONVERT): FPC's -O2 if-conversion lowers a branch-
  predicated ReLU / one-sided clamp / element-wise max-min activation into a
  single-precision min/max intrinsic; -OoIFCONVERT then widens that branch-free
  min/max body across four SSE lanes (packed maxps/minps main loop + scalar
  tail). Verified bit-exact against a scalar recompute for every trip count
  0..17 and 100/1000, exercising all tail residues 0..3. }
program ifconv_relu_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,ra,b: array of single; i: longint;
    lo,hi,x: single;
begin
  SetLength(a,n); SetLength(ra,n); SetLength(b,n);
  lo:=-2.5; hi:=3.5;
  for i:=0 to n-1 do begin a[i]:=(i-7)*0.9; b[i]:=(n-i)*0.3-4; ra[i]:=a[i]; end;
  { transformed loops -- each body is a single if-converted min/max }
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;          { ReLU  -> max(a[i],0) }
  for i:=0 to high(a) do if a[i]<lo then a[i]:=lo;        { clamp -> max(a[i],lo) }
  for i:=0 to high(a) do if a[i]>hi then a[i]:=hi;        { clamp -> min(a[i],hi) }
  for i:=0 to high(a) do if a[i]<b[i] then a[i]:=b[i];    { elem  -> max(a[i],b[i]) }
  { scalar reference (stays a branch; never if-converted the same way here) }
  for i:=0 to n-1 do begin
    x:=ra[i];
    if x<0 then x:=0;
    if x<lo then x:=lo;
    if x>hi then x:=hi;
    if x<b[i] then x:=b[i];
    if a[i]<>x then Halt(1);
  end;
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100); work(1000);
end.
