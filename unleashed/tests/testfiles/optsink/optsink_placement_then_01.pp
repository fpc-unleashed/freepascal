{ %OPT="-O4 -al -s" %NORUN %CHECKASM_ORDER="\tje;imull[ \t]+\$1337" }
{ Assembly placement proof (sink ON).  The multiply  a*1337  is a pure value
  consumed only in the then-arm and dead afterwards, so -OoSINK moves it below
  the guard: the conditional branch (je, which skips over the then-arm) must be
  emitted BEFORE the  imull $1337  in the kept assembly (-al -s).  With the pass
  working the multiply runs only when the then-arm is taken.  The then-arm also
  stores to a global so the if keeps a real branch (not a branchless select),
  making the before/after contrast with optsink_placement_disabled_01 exact.
  Single function so the only conditional jump is the if's own. }
program optsink_placement_then_01;
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
