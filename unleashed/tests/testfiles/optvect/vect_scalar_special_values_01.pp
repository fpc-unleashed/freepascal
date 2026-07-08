{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ The scalar-broadcast and copy shapes propagate NaN, +/-Inf and signed zero
  bit-identically to the scalar path (identical per-lane op, the broadcast puts
  the identical bit pattern of s in every lane, no reassociation). Bit-compared
  via the raw longword pattern (NaN<>NaN so a value compare is not usable). }
program vect_scalar_special_values_01;
{$mode objfpc}{$H+}
uses math;
function bits(s: single): longword; var d: longword absolute s; begin bits:=d; end;
procedure work(s: single);
var a,b: array of single; i,n: longint; d: single;
begin
  n:=11; SetLength(a,n); SetLength(b,n);
  b[0]:=0.0;
  b[1]:=Nan;
  b[2]:=Infinity;
  b[3]:=-Infinity;
  b[4]:=-0.0;
  b[5]:=1.0;
  for i:=6 to n-1 do b[i]:=i*1.25-2;

  for i:=0 to n-1 do a[i]:=b[i]+s;
  for i:=0 to n-1 do begin d:=b[i]+s; if bits(a[i])<>bits(d) then Halt(1); end;
  for i:=0 to n-1 do a[i]:=b[i]*s;
  for i:=0 to n-1 do begin d:=b[i]*s; if bits(a[i])<>bits(d) then Halt(2); end;
  for i:=0 to n-1 do a[i]:=s-b[i];
  for i:=0 to n-1 do begin d:=s-b[i]; if bits(a[i])<>bits(d) then Halt(3); end;
  for i:=0 to n-1 do a[i]:=b[i];
  for i:=0 to n-1 do if bits(a[i])<>bits(b[i]) then Halt(4);
end;
begin
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
  work(Nan);
  work(Infinity);
  work(-0.0);
  work(2.5);
end.
