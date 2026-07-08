{ %OPT="-O4 -OoLOOPSPLIT" }
{ Loop splitting of an IV-vs-invariant-bound conditional. All four monotone
  relations (<, <=, >, >=) and the swapped operand order (m rel i) are split at
  the crossover; the two branch-free loops must reproduce the scalar result for
  every crossover position -- m below, inside and above the iteration range,
  with the range itself empty/short/long. A scalar reference (never split, its
  branch kept) recomputes each element for comparison. }
program split_basic_01;
{$mode objfpc}{$H+}

function r_lt (i,m:longint):longint; begin if i< m then r_lt :=100+i else r_lt :=200+i; end;
function r_le (i,m:longint):longint; begin if i<=m then r_le :=100+i else r_le :=200+i; end;
function r_gt (i,m:longint):longint; begin if i> m then r_gt :=100+i else r_gt :=200+i; end;
function r_ge (i,m:longint):longint; begin if i>=m then r_ge :=100+i else r_ge :=200+i; end;

procedure s_lt (var a: array of longint; n,m:longint); var i:longint;
begin for i:=0 to n-1 do if i< m then a[i]:=100+i else a[i]:=200+i; end;
procedure s_le (var a: array of longint; n,m:longint); var i:longint;
begin for i:=0 to n-1 do if i<=m then a[i]:=100+i else a[i]:=200+i; end;
procedure s_gt (var a: array of longint; n,m:longint); var i:longint;
begin for i:=0 to n-1 do if i> m then a[i]:=100+i else a[i]:=200+i; end;
procedure s_ge (var a: array of longint; n,m:longint); var i:longint;
begin for i:=0 to n-1 do if i>=m then a[i]:=100+i else a[i]:=200+i; end;
{ swapped operand: m>i is the same as i<m }
procedure s_sw (var a: array of longint; n,m:longint); var i:longint;
begin for i:=0 to n-1 do if m>i then a[i]:=100+i else a[i]:=200+i; end;

var a: array[0..31] of longint; i,n,m: longint;
begin
  for n:=0 to 18 do
   for m:=-1 to 20 do
    begin
      for i:=0 to 31 do a[i]:=-1;
      s_lt(a,n,m); for i:=0 to n-1 do if a[i]<>r_lt(i,m) then Halt(1);
      for i:=0 to 31 do a[i]:=-1;
      s_le(a,n,m); for i:=0 to n-1 do if a[i]<>r_le(i,m) then Halt(2);
      for i:=0 to 31 do a[i]:=-1;
      s_gt(a,n,m); for i:=0 to n-1 do if a[i]<>r_gt(i,m) then Halt(3);
      for i:=0 to 31 do a[i]:=-1;
      s_ge(a,n,m); for i:=0 to n-1 do if a[i]<>r_ge(i,m) then Halt(4);
      for i:=0 to 31 do a[i]:=-1;
      s_sw(a,n,m); for i:=0 to n-1 do if a[i]<>r_lt(i,m) then Halt(5);
    end;
  writeln('ok');
end.
