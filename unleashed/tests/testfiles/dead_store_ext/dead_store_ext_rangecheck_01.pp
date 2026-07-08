{ %OPT="-O3 -Oodeadstore -Cr -Co" }
{ Extended DSE must be sound under range/overflow checking: a store whose RHS
  could raise is not a candidate, and constant-index array writes stay in range.
  The program simply has to produce correct results with -Cr -Co on. }
program dead_store_ext_rangecheck_01;
{$mode objfpc}
type
  TRec = record a, b: longint; end;
  TArr = array[0..2] of longint;
var
  g: longint;

procedure P(x: longint);
var r: TRec; a: TArr;
begin
  r.a := x + 1;   { dead }
  r.a := x + 2;   { live }
  r.b := x + 3;
  a[0] := x + 4;  { dead }
  a[0] := x + 5;  { live }
  a[1] := x + 6;
  a[2] := x + 7;
  g := r.a + r.b + a[0] + a[1] + a[2];
end;

begin
  P(100);
  if g <> (100+2)+(100+3)+(100+5)+(100+6)+(100+7) then
    Halt(1);
end.
