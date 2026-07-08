{ %OPT="-O4 -al -s" %NORUN %CHECKASM_ORDER="imull[ \t]+\$1337;\tje" }
{ Negative placement (sink ON, operand redefined before the if).  A statement
  reassigning an operand of the candidate sits between the assignment and the
  if, so the assignment is no longer immediately followed by the guard and the
  recognizer declines it (a missed opportunity is fine, a miscompile is not):
  the pre-if multiply value must be preserved where it was, i.e.  imull $1337
  stays BEFORE the branch (je).  Also proves the pass never sinks across an
  intervening redefinition. }
program optsink_negatives_reassign_01;
{$mode objfpc}{$H+}

function keep(a, b: longint; guard: boolean): longint; noinline;
var d: longint;
begin
  d := a * 1337;
  b := b + a;          { intervening statement: breaks adjacency, touches b }
  if guard then
    keep := d + b
  else
    keep := b;
end;

begin
  Writeln(keep(3, 4, true));
end.
