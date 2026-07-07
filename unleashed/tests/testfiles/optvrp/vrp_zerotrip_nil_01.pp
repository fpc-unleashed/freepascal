{ %OPT="-Cr -O4" }
{ Zero-trip safety: high(nil dynarray) = -1, so the loop runs zero times and
  the (check-eliminated) body is never entered -> no crash. }
{$mode objfpc}
program vrp_zerotrip_nil_01;
function compute: longint;
var a: array of longint; i, s: longint;
begin
  a := nil;
  s := 99;
  for i := 0 to high(a) do s := s + a[i];   { never executes }
  compute := s;
end;
begin
  if compute <> 99 then Halt(1);
  Halt(0);
end.
