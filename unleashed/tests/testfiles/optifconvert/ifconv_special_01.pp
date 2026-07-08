{ %OPT="-O4 -Cfsse64" }
{ Special-value fidelity: the packed maxps/minps must reproduce the scalar
  maxss/minss bit-for-bit for NaN, +0.0/-0.0 and +/-Inf. maxps/minps return
  their SECOND source operand when a lane is unordered, and the recognizer maps
  that second operand to the same value the scalar min/max node uses (the NaN-
  preferred parameter), so the results are identical. FP exceptions are masked
  so the NaN comparisons in the scalar reference do not trap. }
program ifconv_special_01;
{$mode objfpc}{$H+}
uses Math;
function bits(s: single): longword; var l: longword absolute s; begin bits:=l; end;
procedure work(n: longint);
var a,ra,b: array of single; i: longint;
    vals: array[0..6] of single;
begin
  vals[0]:=NaN; vals[1]:=0.0; vals[2]:=-0.0; vals[3]:=-3.0;
  vals[4]:=5.0; vals[5]:=Infinity; vals[6]:=NegInfinity;
  SetLength(a,n); SetLength(ra,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=vals[i mod 7]; ra[i]:=a[i]; b[i]:=vals[(i+3) mod 7]; end;
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;
  for i:=0 to high(a) do if a[i]>2.0 then a[i]:=2.0;
  for i:=0 to high(a) do if a[i]<b[i] then a[i]:=b[i];
  for i:=0 to n-1 do begin
    if ra[i]<0 then ra[i]:=0;
    if ra[i]>2.0 then ra[i]:=2.0;
    if ra[i]<b[i] then ra[i]:=b[i];
    if bits(a[i])<>bits(ra[i]) then Halt(1);
  end;
end;
var k: longint;
begin
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
  for k:=0 to 25 do work(k);
end.
