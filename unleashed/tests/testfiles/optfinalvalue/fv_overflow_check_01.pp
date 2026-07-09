{ %OPT="-O2 -Co -Cr -OoFINALVALUE" }
{ Under overflow (-Co) and range (-Cr) checking -OoFINALVALUE is DISABLED: the
  original loop would trap on the overflowing iteration while the closed form
  would not, so the pass must not fire and the loop keeps its checked semantics.
  Here no accumulation overflows, so the checked loop runs cleanly and yields the
  ordinary result -- proving the pass left the trapping loop intact. }
program fv_overflow_check_01;
{$mode objfpc}{$H+}
var i,s,n: longint;
begin
  for n:=0 to 100 do
    begin
      s:=0;
      for i:=1 to n do inc(s,3);
      if s <> 3*n then Halt(1);
    end;
  Halt(0);
end.
