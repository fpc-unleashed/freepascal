{ %OPT="-O3 -Oodeadstore" }
{ Extended DSE: a redundant constant-index static-array element store is
  removed while the program still produces correct results. }
program dead_store_ext_array_elem_01;
{$mode objfpc}
type
  TArr = array[0..3] of longint;
var
  g: longint;

procedure Build(x: longint);
var
  a: TArr;
begin
  a[0] := x + 999;  { dead: overwritten by a[0] below before any read }
  a[1] := x + 1;
  a[0] := x + 2;    { live }
  a[2] := x + 3;
  a[3] := x + 4;
  g := a[0] + a[1] + a[2] + a[3];
end;

begin
  Build(10);
  if g <> (10 + 2) + (10 + 1) + (10 + 3) + (10 + 4) then
    Halt(1);
end.
