{ %OPT="-Cr -O4" }
{ Case A: static array indexed by a for-counter whose constant bounds lie
  inside the array bounds -> the range check is eliminated; result must still
  be correct and no error may be raised. Uses locals in a function so the
  counter is a proper local (a program-level global is deliberately refused by
  the pass, since a call in the body could alias it). }
{$mode objfpc}
program vrp_static_inbounds_01;
function compute: longint;
var a: array[0..20] of longint; i, s: longint;
begin
  for i := 0 to 20 do a[i] := i;
  s := 0;
  for i := 3 to 10 do s := s + a[i];   { qualifying: [3..10] subset [0..20] }
  compute := s;
end;
begin
  if compute <> 52 then Halt(1);       { 3+4+..+10 = 52 }
  Halt(0);
end.
