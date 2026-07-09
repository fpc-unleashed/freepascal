{ %OPT="-O4 -OoSLP -Cfsse64" }
{ The packed op is a per-lane single-precision op in the same order as scalar,
  with no reassociation, so every lane -- including NaN, +/-Inf and negative
  zero payloads -- must be BIT-identical to the scalar computation. Compared as
  raw 32-bit patterns (LongWord), not with '=' (which treats NaN<>NaN and
  -0.0=+0.0). }
program slp_nan_inf_negzero_01;
{$mode objfpc}{$H+}
uses Math;
type TA = array of single;

procedure add4(a,b,c: TA);
begin
  a[0]:=b[0]+c[0]; a[1]:=b[1]+c[1]; a[2]:=b[2]+c[2]; a[3]:=b[3]+c[3];
end;

procedure mul4(a,b,c: TA);
begin
  a[0]:=b[0]*c[0]; a[1]:=b[1]*c[1]; a[2]:=b[2]*c[2]; a[3]:=b[3]*c[3];
end;

function bits(x: single): longword;
begin
  bits:=plongword(@x)^;
end;

function frombits(w: longword): single;
begin
  frombits:=psingle(@w)^;
end;

var
  a,b,c: TA;
  i: integer;
  posinf,neginf,nan,negzero: single;
begin
  { let NaN/Inf/0-times-Inf produce their IEEE results instead of trapping }
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);

  posinf :=frombits($7F800000);
  neginf :=frombits($FF800000);
  nan    :=frombits($7FC00000);
  negzero:=frombits($80000000);

  SetLength(a,4); SetLength(b,4); SetLength(c,4);
  b[0]:=posinf; c[0]:=neginf;   { Inf + (-Inf) = NaN }
  b[1]:=nan;    c[1]:=1.0;      { NaN + 1 = NaN }
  b[2]:=negzero;c[2]:=negzero;  { -0.0 + -0.0 = -0.0 }
  b[3]:=posinf; c[3]:=1.0;      { Inf + 1 = Inf }

  add4(a,b,c);
  for i:=0 to 3 do if bits(a[i])<>bits(b[i]+c[i]) then Halt(1+i);

  b[0]:=negzero; c[0]:=1.0;     { -0.0 * 1 = -0.0 }
  b[1]:=negzero; c[1]:=-1.0;    { -0.0 * -1 = +0.0 }
  b[2]:=posinf;  c[2]:=0.0;     { Inf * 0 = NaN }
  b[3]:=nan;     c[3]:=nan;     { NaN * NaN = NaN }

  mul4(a,b,c);
  for i:=0 to 3 do if bits(a[i])<>bits(b[i]*c[i]) then Halt(5+i);
end.
