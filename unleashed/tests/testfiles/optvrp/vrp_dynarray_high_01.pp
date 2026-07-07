{ %OPT="-Cr -O4" }
{ Case B: dynamic array indexed by a for-counter bounded by high(a) -> both the
  fpc_dynarray_rangecheck and the index check are eliminated; result correct. }
{$mode objfpc}
program vrp_dynarray_high_01;
function compute: longint;
var a: array of longint; i, s: longint;
begin
  SetLength(a, 8);
  for i := 0 to high(a) do a[i] := i + 1;
  s := 0;
  for i := 0 to high(a) do s := s + a[i];   { 1+2+..+8 = 36 }
  compute := s;
end;
begin
  if compute <> 36 then Halt(1);
  Halt(0);
end.
