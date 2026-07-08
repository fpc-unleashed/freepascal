{ %OPT=-O4 }
{ Unroll-and-jam remainder handling (-O4 -OoUNROLLJAM).  The outer loop is
  unrolled by 4, so an outer trip count that is not a multiple of 4 leaves a
  scalar-outer remainder loop for the last 1..3 rows.  This exercises every
  residue class 0,1,2,3 of the outer trip count (and the empty and single-row
  cases) against a completely independent, single-flat-loop absolute reference,
  so a wrong remainder count -- dropping or double-counting the tail rows --
  would change a produced element and fail.  Inner bounds are passed at run time
  (non-constant), which is the case that must emit the remainder correctly. }
program unrolljam_remainder_01;
{$mode objfpc}{$H+}

const MAXN = 40; MAXM = 40;

procedure mm(n,m:longint; out c:array of double);
var a:array[0..MAXN-1,0..MAXM-1] of double; b:array[0..MAXM-1] of double;
    i,j:longint; s:double;
begin
  for i:=0 to n-1 do for j:=0 to m-1 do a[i,j]:=((i*9+j*4) mod 19)-9.0;
  for j:=0 to m-1 do b[j]:=((j*3) mod 7)-3.0;
  for i:=0 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do
      s:=s+a[i,j]*b[j];
    c[i]:=s;
  end;
end;

function elem(i,m:longint):double;
var j:longint; s:double;
begin
  s:=0;
  for j:=0 to m-1 do
    s:=s+(((i*9+j*4) mod 19)-9.0)*(((j*3) mod 7)-3.0);
  elem:=s;
end;

var c:array[0..MAXN-1] of double; n,m,i:longint;
begin
  for n:=0 to 12 do          { residues 0,1,2,3 several times, plus 0 and 1 }
    for m:=1 to 9 do
      begin
        mm(n,m,c);
        for i:=0 to n-1 do
          if c[i]<>elem(i,m) then Halt(1+((n*13+m) and 63));
      end;
  Halt(0);
end.
