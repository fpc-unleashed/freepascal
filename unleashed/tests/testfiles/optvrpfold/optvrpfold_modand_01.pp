{ %OPT="-O4" %CHECKBIN_LACKS="ZZVRPMODDEAD,ZZVRPANDDEAD" %CHECKBIN_HAS="ZZVRPMODLIVE,ZZVRPANDLIVE" }
{ -OoVRP straight-line interval seeds.  n:=x mod 100 constrains n to [-99..99],
  so  if n>=1000  folds to always-false (ZZVRPMODDEAD deleted).  m:=x and 63
  constrains m to [0..63], so  if m>200  folds to always-false (ZZVRPANDDEAD
  deleted).  Neither range is known to constant propagation, jump threading or
  the front end, so this fold is unique to VRP.  Behaviour is unchanged: the mod
  and the and still execute, only the dead compares' arms are removed. }
program optvrpfold_modand_01;
{$mode objfpc}{$H+}

function seed: longint; noinline;
begin
  { ParamCount is a runtime value the optimizer cannot predict, so n and m are
    genuinely unknown at compile time -- only their mod/and-derived RANGES are
    known, which is exactly what VRP exploits (with the switch off, nothing
    folds these compares; see optvrpfold_disabled_01). }
  seed := 1234567 + ParamCount;
end;

procedure run; noinline;
var
  n, m: longint;
begin
  n := seed mod 100;
  if n >= 1000 then
    Writeln('ZZVRPMODDEAD')
  else
    Writeln('ZZVRPMODLIVE');

  m := seed and 63;
  if m > 200 then
    Writeln('ZZVRPANDDEAD')
  else
    Writeln('ZZVRPANDLIVE');

  { observable sanity: the real values are within the proven ranges }
  if (n < -99) or (n > 99) then Halt(1);
  if (m < 0) or (m > 63) then Halt(2);
end;

begin
  run;
end.
