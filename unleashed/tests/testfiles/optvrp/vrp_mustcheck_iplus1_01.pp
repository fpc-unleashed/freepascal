{ %OPT="-Cr -O4" }
{ Must STILL check: the index is i+1 (an offset, not the plain counter), so at
  i=high(a) it reaches out of bounds and -Cr must raise ERangeError. The array
  and counter are locals, so the pass genuinely evaluates the loop and must
  DECLINE (offset index). run() has no exception frame so DFA is available. }
{$mode objfpc}
program vrp_mustcheck_iplus1_01;
uses sysutils;
var g: longint;
procedure run;
var a: array of longint; i: longint;
begin
  SetLength(a, 8);
  for i := 0 to high(a) do g := g + a[i+1];   { i+1 OOB at i=high }
end;
begin
  g := 0;
  try
    run;
    Halt(1);           { no error raised -> WRONG (check was elided) }
  except
    on E: ERangeError do Halt(0);
  end;
  Halt(2);
end.
