{ %OPT="-O4 -OoPARTIALINLINE" }
{ Shapes that the pass must conservatively refuse to split (routine with a
  try/finally, and a routine with a nested procedure) still have to compile and
  run with exactly the original semantics under the switch. Wrong results Halt
  with a distinct code. }
program optpartialinline_skip_01;
{$mode objfpc}

var
  acc: int64 = 0;

{ SKIP: has try/finally }
procedure GuardedTry(x: longint);
begin
  if x <= 0 then
    exit;
  try
    acc := acc + x;
  finally
    acc := acc + 1;
  end;
end;

{ SKIP: has a nested procedure }
procedure GuardedNested(x: longint);

  procedure Bump;
  begin
    acc := acc + 100;
  end;

begin
  if x <= 0 then
    exit;
  Bump;
end;

var
  zero, pos: longint;
begin
  zero := 0; pos := 4;
  if ParamCount > 1000 then begin zero := 1; pos := 1; end;

  GuardedTry(zero);   { no-op }
  GuardedTry(pos);    { acc += 4 + 1 = 5 }
  if acc <> 5 then Halt(1);

  GuardedNested(zero); { no-op }
  GuardedNested(pos);  { acc += 100 }
  if acc <> 105 then Halt(2);
end.
