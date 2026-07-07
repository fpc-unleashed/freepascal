{ %OPT="-Cr -O4" }
{ Case B spelling: for i := 0 to length(a)-1 is the same largest valid index as
  high(a); check eliminated, result correct. }
{$mode objfpc}
program vrp_dynarray_lenm1_01;
function compute: longint;
var a: array of longint; i, s: longint;
begin
  SetLength(a, 5);
  for i := 0 to length(a)-1 do a[i] := 2;
  s := 0;
  for i := 0 to length(a)-1 do s := s + a[i];   { 5*2 = 10 }
  compute := s;
end;
begin
  if compute <> 10 then Halt(1);
  Halt(0);
end.
