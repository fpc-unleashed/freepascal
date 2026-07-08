{ %OPT="-O4" }
{ Negative case: a routine with a try/finally (implicit exception frame) must NOT
  get sibling-call frame reuse - there is pending cleanup that has to run and the
  frame teardown is not a plain stack release.  The pass gates on
  pi_uses_exceptions / pi_*implicit_finally.  Behaviour must stay correct. }
program optsibcall_tryfinally_negative_01;
{$mode objfpc}

var
  total: int64 = 0;

procedure sink(n: longint); forward;

procedure src(n: longint);
var
  a: array[0..7] of longint;
  i: longint;
begin
  for i := 0 to 7 do a[i] := n + i;
  try
    total := total + a[0];
  finally
    total := total + 1;
  end;
  if n > 0 then sink(n - 1);
end;

procedure sink(n: longint);
var
  b: array[0..7] of longint;
  i: longint;
begin
  for i := 0 to 7 do b[i] := n * 2 - i;
  total := total + b[0];
  if n > 0 then src(n - 1);
end;

begin
  src(6);
  { src runs at n=6,4,2,0 : a[0]=n plus finally +1 each -> (6+4+2+0)+4 = 16
    sink runs at n=5,3,1   : b[0]=n*2 -> 10+6+2 = 18  => total 34 }
  if total <> 34 then Halt(1);
end.
