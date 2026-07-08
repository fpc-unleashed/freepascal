{ %OPT="-O4" }
{ Negative case: a routine with a managed (ref-counted) local needs implicit
  finalization on exit, so its teardown is not a plain stack release and it must
  NOT get sibling-call frame reuse.  The pass gates on pi_needs_implicit_finally.
  Behaviour must stay correct. }
program optsibcall_managed_negative_01;
{$mode objfpc}{$H+}

var
  total: int64 = 0;

procedure sink(n: longint); forward;

procedure src(n: longint);
var
  s: ansistring;
  a: array[0..7] of longint;
  i: longint;
begin
  for i := 0 to 7 do a[i] := n + i;
  s := 'value';
  if a[0] > 0 then s := s + 'x';
  total := total + length(s);
  if n > 0 then sink(n - 1);
end;

procedure sink(n: longint);
var
  a: array[0..7] of longint;
  i: longint;
begin
  for i := 0 to 7 do a[i] := n - i;
  total := total + a[0];
  if n > 0 then src(n - 1);
end;

begin
  src(4);
  { src at n=4,2,0 : length('value')=5, plus 'x' when a[0]=n>0 (n=4,2) -> 6+6+5 = 17
    sink at n=3,1   : a[0]=n -> 3+1 = 4  => total 21 }
  if total <> 21 then Halt(1);
end.
