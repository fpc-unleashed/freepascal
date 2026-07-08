{ %OPT="-O4 -OoNOSINK -al -s" %NORUN %CHECKASM_ORDER="imull[ \t]+\$1337;\tje" }
{ Assembly placement control (sink OFF).  The exact same single-function shape
  as optsink_placement_then_01, but with -OoNOSINK.  Now the multiply must stay
  ABOVE the guard: in the kept assembly  imull $1337  is emitted BEFORE the
  conditional branch (je), i.e. computed unconditionally, proving the reordering
  in the enabled build is the pass's doing and nothing else moves it. }
program optsink_placement_disabled_01;
{$mode objfpc}{$H+}

var
  g: longint;

function sinkme(a: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * 1337;
  if guard then
    begin g := a; sinkme := d end
  else
    sinkme := 0;
end;

begin
  g := 0;
  Writeln(sinkme(3, true), ' ', g);
end.
