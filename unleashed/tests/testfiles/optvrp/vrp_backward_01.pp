{ %OPT="-Cr -O4" }
{ Backward counted loop still keeps i within [0,high(a)]. }
{$mode objfpc}
program vrp_backward_01;
function compute: longint;
var a: array of longint; i, s: longint;
begin
  SetLength(a, 6);
  for i := high(a) downto 0 do a[i] := i;
  s := 0;
  for i := high(a) downto 0 do s := s + a[i];   { 0+1+..+5 = 15 }
  compute := s;
end;
begin
  if compute <> 15 then Halt(1);
  Halt(0);
end.
