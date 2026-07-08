{ %OPT="-O4" %CHECKBIN_LACKS="ZZVRPSUBDEAD" %CHECKBIN_HAS="ZZVRPSUBLIVE" }
{ -OoVRP folds a comparison decided by a variable's declared subrange TYPE: s has
  type 0..100, so  if s>150  is always false and the ZZVRPSUBDEAD arm is deleted.
  (FPC's front end already narrows some literal subrange compares; VRP handles
  the type-range case uniformly within the interval framework and composes with
  the flowed for-loop and mod/and facts.)  The run confirms the kept path. }
program optvrpfold_subrange_01;
{$mode objfpc}{$H+}

type
  tsmall = 0..100;

function make(v: longint): tsmall; noinline;
begin
  make := tsmall(v and 63);   { always a valid 0..63 in-range value }
end;

procedure run; noinline;
var
  s: tsmall;
begin
  s := make(200);
  if s > 150 then
    Writeln('ZZVRPSUBDEAD')
  else
    Writeln('ZZVRPSUBLIVE');
  if s > 100 then
    Halt(1);
end;

begin
  run;
end.
