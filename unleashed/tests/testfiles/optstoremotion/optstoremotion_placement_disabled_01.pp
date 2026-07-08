{ %OPT="-O4 -OoNOSTOREMOTION -al -s" %NORUN %CHECKASM_ORDER=",U_[A-Za-z0-9_\$]*_\$\$_G;jnle" }
{ Control for optstoremotion_placement_01: identical source with loop store
  motion DISABLED (-OoNOSTOREMOTION).  Without the pass the global g is written
  through memory INSIDE the loop, so a reference storing to g (g as destination:
  ,U_..._G ) is emitted BEFORE the loop's back-edge conditional jump (jnle).  The
  CHECKASM_ORDER asserts that inside-the-loop ordering, the exact opposite of the
  enabled build, making the before/after contrast explicit. }
program optstoremotion_placement_disabled_01;
{$mode objfpc}{$H+}

var
  g: longint;

function acc(n: longint): longint; noinline;
var i: longint;
begin
  for i := 1 to n do
    g := g + i;
  acc := g;
end;

function peek: longint; noinline; begin peek := g; end;

begin
  g := 0;
  Writeln(acc(10), ' ', peek);
end.
