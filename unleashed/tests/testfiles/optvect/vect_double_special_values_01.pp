{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Double-precision packed ops propagate NaN, +/-Inf and signed zero
  bit-identically to the scalar path (identical per-lane op, no reassociation).
  Bit-compared via the raw qword pattern (NaN<>NaN so a value compare is not
  usable). FP exceptions are masked so the special values flow through instead
  of trapping. }
program vect_double_special_values_01;
{$mode objfpc}{$H+}
uses math;
function qb(x: double): qword; var q: qword absolute x; begin qb:=q; end;
procedure work;
var a,b,c: array of double; i,n: longint; d: double;
begin
  n:=11; SetLength(a,n); SetLength(b,n); SetLength(c,n);
  b[0]:=0.0;      c[0]:=-0.0;
  b[1]:=Nan;      c[1]:=1.0;
  b[2]:=Infinity; c[2]:=1.0;
  b[3]:=Infinity; c[3]:=Infinity;
  b[4]:=-Infinity;c[4]:=Infinity;
  b[5]:=-0.0;     c[5]:=0.0;
  for i:=6 to n-1 do begin b[i]:=i*1.25-2; c[i]:=i*0.5+0.3; end;
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
  for i:=0 to n-1 do begin d:=b[i]+c[i]; if qb(a[i])<>qb(d) then Halt(1); end;
  for i:=0 to n-1 do a[i]:=b[i]*c[i];
  for i:=0 to n-1 do begin d:=b[i]*c[i]; if qb(a[i])<>qb(d) then Halt(2); end;
  for i:=0 to n-1 do a[i]:=b[i]-c[i];
  for i:=0 to n-1 do begin d:=b[i]-c[i]; if qb(a[i])<>qb(d) then Halt(3); end;
end;
begin
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
  work;
end.
