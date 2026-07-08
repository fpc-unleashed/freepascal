{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfsse64" }
{ NaN and +/-Inf propagate through the packed reduction exactly as through a
  sequential sum: NaN+x=NaN, (+Inf)+finite=+Inf, (-Inf)+finite=-Inf.  (Unlike the
  bit-exact element-wise store shapes, a partial-sum reduction reassociates the
  adds under fast-math, so the SIGN of a pure -0.0 sum is not guaranteed -- a
  +0.0 lane seed absorbs it -- hence -0.0 is checked only by VALUE, which treats
  -0.0 = 0.0.) }
program vect_reduce_special_values_01;
{$mode objfpc}{$H+}
uses math;
procedure work;
var a,b: array of single; i,n: longint; s: single;
begin
  n:=23; SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=1.0; b[i]:=2.0; end;

  { +Inf anywhere -> +Inf sum }
  a[9]:=Infinity;
  s:=0; for i:=0 to n-1 do s:=s+a[i];
  if not (IsInfinite(s) and (s>0)) then Halt(1);

  { -Inf anywhere -> -Inf sum }
  a[9]:=-Infinity;
  s:=0; for i:=0 to n-1 do s:=s+a[i];
  if not (IsInfinite(s) and (s<0)) then Halt(2);

  { NaN anywhere -> NaN sum }
  a[9]:=1.0; a[14]:=Nan;
  s:=0; for i:=0 to n-1 do s:=s+a[i];
  if not IsNan(s) then Halt(3);

  { NaN factor -> NaN dot }
  a[14]:=1.0; a[3]:=Nan;
  s:=0; for i:=0 to n-1 do s:=s+a[i]*b[i];
  if not IsNan(s) then Halt(4);

  { pure -0.0 sum: value is zero (sign not asserted under fast-math) }
  for i:=0 to n-1 do a[i]:=-0.0;
  s:=-0.0; for i:=0 to n-1 do s:=s+a[i];
  if s<>0.0 then Halt(5);
end;
begin
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
  work;
end.
