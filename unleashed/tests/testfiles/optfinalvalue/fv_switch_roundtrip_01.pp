{ %OPT="-O2 -OoFINALVALUE,NOFINALVALUE" }
{ The -Oofinalvalue,NOFINALVALUE switch pair must round-trip: enabling then
  disabling the pass leaves it OFF, the program compiles and runs correctly with
  the ordinary counted loop. (A companion run with the pass ON lives in the
  other tests; this one asserts the negated form parses and is a no-op.) }
program fv_switch_roundtrip_01;
{$mode objfpc}{$H+}
var i,s,n: longint;
begin
  for n:=0 to 30 do
    begin
      s:=11;
      for i:=1 to n do inc(s,6);
      if s <> 11 + 6*n then Halt(1);
    end;
  Halt(0);
end.
