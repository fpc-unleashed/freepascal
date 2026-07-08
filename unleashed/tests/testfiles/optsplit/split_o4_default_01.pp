{ %OPT="-O4 -vn" }
{ Loop splitting is part of the -O4 default optimizer set, so it fires without an
  explicit -OoLOOPSPLIT. An IV-vs-invariant-bound conditional loop splits at the
  crossover; the result must match the scalar branch. (Compiled at plain -O4;
  the note confirms the pass ran as a default.) }
program split_o4_default_01;
{$mode objfpc}{$H+}

procedure clampfill(var a: array of longint; n, m: longint);
var i: longint;
begin
  for i:=0 to n-1 do
    if i<m then a[i]:=i*i else a[i]:=(i-m)*3 + 7;
end;

var a: array[0..31] of longint; i, n, m: longint;
begin
  n:=20; m:=8;
  for i:=0 to 31 do a[i]:=-1;
  clampfill(a, n, m);
  for i:=0 to n-1 do
    if i<m then
      begin if a[i]<>i*i then Halt(1); end
    else
      if a[i]<>(i-m)*3+7 then Halt(2);
  writeln('ok');
end.
