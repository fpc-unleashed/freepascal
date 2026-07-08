{ %OPT=-O4 }
{ Predictive commoning (-O4 -OoPREDCOM) must carry a cross-iteration reload
  window in rotating temporaries and produce a result BIT-IDENTICAL to the
  untransformed loop for every input.  Three shapes are checked against an
  independent element-wise reference recomputed from the same source values:
  a 3-wide double stencil  a[i]:=b[i-1]+b[i]+b[i+1], a 2-wide int32 sliding
  window  a[i]:=b[i]*2+b[i+1]*3, and a 3-wide Single stencil -- across trip
  counts 0,1,2,3 (window boundary and the  if lo<=hi  guard) and larger sizes
  200..205 that hit every residue.  The commoned value is the exact stored
  element, so double/single equality is exact. }
program predcom_correct_01;
{$mode objfpc}{$H+}

function dval(i: longint): double; begin dval := i*1.5 - 3.25 + (i mod 7)*0.5; end;
function sval(i: longint): single; begin sval := i*0.25 - 1.5 + (i mod 5)*0.125; end;
function ival(i: longint): longint; begin ival := (i*7) mod 17 - 8; end;

{ 3-wide double stencil: reads local b[i-1],b[i],b[i+1], writes out param a }
procedure sten3d(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);          { fill: calls dval, declined }
  for i:=1 to n-2 do a[i]:=b[i-1]+b[i]+b[i+1];
end;

{ 2-wide int32 window }
procedure win2i(var a: array of longint; n: longint);
var b: array of longint; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=ival(i);
  for i:=0 to n-2 do a[i]:=b[i]*2+b[i+1]*3;
end;

{ 3-wide single stencil }
procedure sten3s(var a: array of single; n: longint);
var b: array of single; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=sval(i);
  for i:=1 to n-2 do a[i]:=b[i-1]+b[i]+b[i+1];
end;

procedure checkd(n: longint);
var a: array of double; i: longint; exp: double;
begin
  setlength(a,n);
  for i:=0 to n-1 do a[i]:=-999;
  sten3d(a,n);
  for i:=0 to n-1 do
    begin
      if (i>=1) and (i<=n-2) then exp:=dval(i-1)+dval(i)+dval(i+1)
      else exp:=-999;
      if a[i]<>exp then Halt(1);
    end;
end;

procedure checki(n: longint);
var a: array of longint; i: longint; exp: longint;
begin
  setlength(a,n);
  for i:=0 to n-1 do a[i]:=-999;
  win2i(a,n);
  for i:=0 to n-1 do
    begin
      if i<=n-2 then exp:=ival(i)*2+ival(i+1)*3
      else exp:=-999;
      if a[i]<>exp then Halt(2);
    end;
end;

procedure checks(n: longint);
var a: array of single; i: longint; exp: single;
begin
  setlength(a,n);
  for i:=0 to n-1 do a[i]:=-999;
  sten3s(a,n);
  for i:=0 to n-1 do
    begin
      if (i>=1) and (i<=n-2) then exp:=sval(i-1)+sval(i)+sval(i+1)
      else exp:=-999;
      if a[i]<>exp then Halt(3);
    end;
end;

var n: longint;
begin
  for n:=0 to 8 do begin checkd(n); checki(n); checks(n); end;
  for n:=200 to 205 do begin checkd(n); checki(n); checks(n); end;
  Halt(0);
end.
