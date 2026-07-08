{ %OPT="-O4 -al -s" %NORUN %CHECKASM_ORDER="imull[ \t]+\$1337;\tje" }
{ Negative placement (sink ON, but the shape is not sinkable).  The value d is
  consumed on BOTH arms of the if, so -OoSINK must NOT move it -- there is no
  single arm that owns it, and lowering it into one would leave the other arm
  reading an undefined d.  The multiply  imull $1337  must therefore still be
  emitted BEFORE the guard's conditional branch (je), exactly as without the
  pass. }
program optsink_negatives_botharms_01;
{$mode objfpc}{$H+}

function keep(a: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * 1337;
  if guard then
    keep := d + 1
  else
    keep := d - 1;
end;

begin
  Writeln(keep(3, true));
end.
