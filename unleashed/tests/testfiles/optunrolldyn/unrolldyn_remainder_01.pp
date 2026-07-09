{ %OPT="-O3 -OoUNROLLDYN -OoPREFETCH" }
{ -OoUNROLLDYN unrolls a counted for-loop of UNKNOWN trip count by 4 with a
  scalar remainder loop. This test exercises the remainder for the boundary trip
  counts 0, 1, 3, 4, 5 and a long 1000, on the element-wise store shape
  a[i]:=b[i]*s and the plain-copy shape a[i]:=b[i]. Each result is checked
  against a closed-form value that does not depend on the loop structure, so it
  passes whether or not the loop is unrolled -- the point is that the unrolled
  main loop plus the remainder together cover exactly the same iteration space
  as the scalar loop. Halt(N) pinpoints the failing trip count / shape. }
program unrolldyn_remainder_01;
{$mode objfpc}{$H+}

type
  TA = array of single;

{ these routines are the unroll targets: local counter, straight-line body,
  every array access indexed by the bare counter }
procedure scale(a, b: TA; n: integer; s: single);
var i: integer;
begin
  for i := 0 to n-1 do
    a[i] := b[i] * s;
end;

procedure copy(a, b: TA; n: integer);
var i: integer;
begin
  for i := 0 to n-1 do
    a[i] := b[i];
end;

procedure check(n, code: integer);
var
  a, b: TA;
  i: integer;
begin
  SetLength(a, n+1);      { one guard slot so n=0 still has valid storage }
  SetLength(b, n+1);
  for i := 0 to n do
    begin
      a[i] := -999;       { poison }
      b[i] := i * 0.25 - 3;
    end;

  scale(a, b, n, 2.5);
  for i := 0 to n-1 do
    if a[i] <> b[i] * 2.5 then
      Halt(code);
  { the guard slot must be untouched (no over-write past hi) }
  if a[n] <> -999 then
    Halt(code+100);

  for i := 0 to n do
    a[i] := -777;
  copy(a, b, n);
  for i := 0 to n-1 do
    if a[i] <> b[i] then
      Halt(code+200);
  if a[n] <> -777 then
    Halt(code+300);
end;

begin
  check(0, 1);
  check(1, 2);
  check(3, 3);
  check(4, 4);
  check(5, 5);
  check(1000, 6);
  WriteLn('ok');
end.
