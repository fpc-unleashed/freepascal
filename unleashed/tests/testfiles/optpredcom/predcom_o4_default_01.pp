{ %OPT=-O4 }
{ Plain -O4 (no explicit -Oo switch) must enable predictive commoning, because
  cs_opt_predcom is a member of genericlevel4optimizerswitches.  Smoke test that
  the default -O4 pipeline both fires the transform and stays correct: a 5-wide
  double stencil (window -2..+2) is checked element-wise against an independent
  reference over several trip counts including the empty and window-boundary
  cases. }
program predcom_o4_default_01;
{$mode objfpc}{$H+}

function dval(i: longint): double; begin dval := i*0.75 + (i mod 3)*0.5 - 2.0; end;

{ 5-wide stencil, offsets -2..+2 }
procedure sten5(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  for i:=2 to n-3 do a[i]:=b[i-2]+b[i-1]+b[i]+b[i+1]+b[i+2];
end;

var a: array of double; i, n: longint;
begin
  for n:=0 to 10 do
    begin
      setlength(a,n);
      for i:=0 to n-1 do a[i]:=-13;
      sten5(a,n);
      for i:=0 to n-1 do
        if (i>=2) and (i<=n-3) then
          begin
            if a[i]<>dval(i-2)+dval(i-1)+dval(i)+dval(i+1)+dval(i+2) then Halt(1);
          end
        else
          if a[i]<>-13 then Halt(2);
    end;
  for n:=250 to 254 do
    begin
      setlength(a,n);
      for i:=0 to n-1 do a[i]:=-13;
      sten5(a,n);
      for i:=2 to n-3 do
        if a[i]<>dval(i-2)+dval(i-1)+dval(i)+dval(i+1)+dval(i+2) then Halt(3);
    end;
  Halt(0);
end.
