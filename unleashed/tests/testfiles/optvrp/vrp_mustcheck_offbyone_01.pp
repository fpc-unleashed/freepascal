{ %OPT="-Cr -O4" }
{ Must STILL check: for i := 0 to length(a) is off-by-one (length, not
  length-1); the pass rejects a plain length() bound, so at i=length(a) the OOB
  access must raise. }
{$mode objfpc}
program vrp_mustcheck_offbyone_01;
uses sysutils;
var g: longint;
procedure run;
var a: array of longint; i: longint;
begin
  SetLength(a, 8);
  for i := 0 to length(a) do g := g + a[i];   { i=length(a) is OOB }
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
