{ %OPT="-O4" %CHECKBIN_LACKS="ZZVRPDEADFOR" %CHECKBIN_HAS="ZZVRPLIVEFOR" }
{ -OoVRP interval branch folding: inside  for i:=0 to 5  the counter is provably
  in [0..5], so the nested  if i>10  is always false and its then-arm (with the
  ZZVRPDEADFOR marker) is deleted at -O4, keeping only the else-arm.  This is the
  fold no other landed pass performs: the loop bounds are constants but the
  comparison constant (10) is outside the counter's range.  CHECKBIN asserts the
  dead marker is gone and the live marker (reached on the kept path) remains; the
  body also Halts non-zero if the dead arm ever executed. }
program optvrpfold_forloop_01;
{$mode objfpc}{$H+}

var
  sink: longint;

procedure run; noinline;
var
  i, hits: longint;
begin
  hits := 0;
  for i := 0 to 5 do
    if i > 10 then
      begin
        Writeln('ZZVRPDEADFOR');
        Inc(hits);
      end
    else
      Inc(sink);
  if hits <> 0 then
    Halt(1);            { the always-false arm must never run }
  Writeln('ZZVRPLIVEFOR');
end;

begin
  sink := 0;
  run;
  if sink <> 6 then     { the else-arm ran once per iteration }
    Halt(2);
end.
