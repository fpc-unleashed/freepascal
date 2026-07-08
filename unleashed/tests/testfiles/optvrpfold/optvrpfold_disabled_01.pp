{ %OPT="-O4 -OoNOVRP" %CHECKBIN_HAS="ZZVRPMODDEAD,ZZVRPANDDEAD" }
{ Control for optvrpfold_modand_01: with -OoVRP switched OFF (but every other -O4
  optimization on), no pass knows the  mod / and  derived ranges, so both dead
  compares' arms survive -- their markers ZZVRPMODDEAD and ZZVRPANDDEAD are still
  present in the binary.  This proves the folding in optvrpfold_modand_01 is
  attributable to VRP specifically.  Same source, same runtime behaviour. }
program optvrpfold_disabled_01;
{$mode objfpc}{$H+}

function seed: longint; noinline;
begin
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

  if (n < -99) or (n > 99) then Halt(1);
  if (m < 0) or (m > 63) then Halt(2);
end;

begin
  run;
end.
