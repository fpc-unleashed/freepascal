{ %OPT="-O4" %CHECKBIN_HAS="ZZVRPTHENKEPT" %CHECKBIN_LACKS="ZZVRPELSEDEAD" }
{ -OoVRP: a provably-TRUE guard keeps only the then-arm.  Inside  for i:=0 to 5
  the counter is in [0..5], so  if i<100  is always true; the else-arm (with the
  ZZVRPELSEDEAD marker) is deleted and the then-arm (ZZVRPTHENKEPT) kept. }
program optvrpfold_truearm_01;
{$mode objfpc}{$H+}

var
  sink: longint;

procedure run; noinline;
var
  i, elsehits: longint;
begin
  elsehits := 0;
  for i := 0 to 5 do
    if i < 100 then
      Inc(sink)
    else
      begin
        Writeln('ZZVRPELSEDEAD');
        Inc(elsehits);
      end;
  if elsehits <> 0 then
    Halt(1);
  Writeln('ZZVRPTHENKEPT');
end;

begin
  sink := 0;
  run;
  if sink <> 6 then
    Halt(2);
end.
