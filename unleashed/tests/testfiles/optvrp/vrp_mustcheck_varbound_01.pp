{ %OPT="-Cr -O4" }
{ Must STILL check: the loop's upper bound is a runtime variable (not a
  constant and not high(a)), so the pass cannot prove the index in range and
  must DECLINE; when the bound exceeds the static array, the OOB access must
  raise ERangeError. The array and counter are locals so the pass genuinely
  evaluates the loop. }
{$mode objfpc}
program vrp_mustcheck_varbound_01;
uses sysutils;
var g: longint;
procedure run(n: longint);
var a: array[0..5] of longint; i: longint;
begin
  for i := 0 to n do g := g + a[i];   { n=10 at call -> i>5 OOB, must raise }
end;
begin
  g := 0;
  try
    run(10);
    Halt(1);
  except
    on E: ERangeError do Halt(0);
  end;
  Halt(2);
end.
