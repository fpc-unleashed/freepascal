{ %OPT="-Cr -O4" }
{ Must STILL check: the array is SetLength'd smaller inside the loop, so a later
  access is OOB and must raise. SetLength(a,..) takes a by reference (address
  taken), which disqualifies the pass -> the check stays. }
{$mode objfpc}
program vrp_mustcheck_setlength_01;
uses sysutils;
var g: longint;
procedure run;
var a: array of longint; i: longint;
begin
  SetLength(a, 10);
  for i := 0 to high(a) do
    begin
      if i = 3 then SetLength(a, 4);   { shrink; high was 9, now 3 }
      g := g + a[i];                   { i=4 -> OOB, must raise }
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
