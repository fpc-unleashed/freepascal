{ %OPT="-Cr -O4" }
{ Must STILL check: a manually computed index (a different variable) is not the
  loop counter, so its check is not eliminated and an OOB value must raise. }
{$mode objfpc}
program vrp_mustcheck_manual_01;
uses sysutils;
var g: longint;
procedure run;
var a: array of longint; i, j: longint;
begin
  SetLength(a, 8);
  for i := 0 to high(a) do
    begin
      j := i * 3;        { grows past high(a) }
      g := g + a[j];     { OOB, must raise }
    end;
end;
begin
  g := 0;
  try
    run;
    Halt(1);
  except
    on E: ERangeError do Halt(0);
  end;
  Halt(2);
end.
