{ %OPT="-O4" %CHECKBIN_HAS="ZZVRPBOTHA,ZZVRPBOTHB" }
{ -OoVRP must DECLINE to fold when the interval genuinely straddles the compare
  constant.  Inside  for i:=0 to 20  the counter is in [0..20], which overlaps
  both sides of  i>10 , so the outcome varies per iteration and BOTH arms must
  survive.  CHECKBIN asserts both markers remain; the run cross-checks the exact
  split (11 iterations take the then-arm, 10 the else-arm). }
program optvrpfold_nofold_01;
{$mode objfpc}{$H+}

var
  thn, els: longint;

procedure run; noinline;
var
  i: longint;
begin
  thn := 0;
  els := 0;
  for i := 0 to 20 do
    if i > 10 then
      begin
        if i = 11 then Writeln('ZZVRPBOTHA');
        Inc(thn);
      end
    else
      begin
        if i = 0 then Writeln('ZZVRPBOTHB');
        Inc(els);
      end;
end;

begin
  run;
  if thn <> 10 then Halt(1);   { i = 11..20 }
  if els <> 11 then Halt(2);   { i = 0..10 }
end.
