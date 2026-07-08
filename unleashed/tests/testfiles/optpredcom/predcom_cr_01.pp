{ %OPT="-O4 -Cr -Co" }
{ Under range/overflow checking the pass declines outright (it does not want to
  reorder or drop any per-element check), so -Cr/-Co code is left exactly as
  written: no new out-of-bounds or speculative load is ever introduced at the
  edges of the window, at trip count 0/1, or anywhere else.  The stencil is run
  with -Cr active over trip counts that put the window flush against both array
  ends; it must complete without a range-check error and match the reference. }
program predcom_cr_01;
{$mode objfpc}{$H+}

function dval(i: longint): double; begin dval := i*1.25 - 0.5; end;

procedure sten3d(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  for i:=1 to n-2 do a[i]:=b[i-1]+b[i]+b[i+1];
end;

var a: array of double; i, n: longint;
begin
  for n:=0 to 6 do
    begin
      setlength(a,n);
      for i:=0 to n-1 do a[i]:=-7;
      sten3d(a,n);
      for i:=0 to n-1 do
        if (i>=1) and (i<=n-2) then
          begin if a[i]<>dval(i-1)+dval(i)+dval(i+1) then Halt(1); end
        else
          if a[i]<>-7 then Halt(2);
    end;
  Halt(0);
end.
