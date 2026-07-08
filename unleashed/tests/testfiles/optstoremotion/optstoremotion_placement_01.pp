{ %OPT="-O4 -al -s" %NORUN %CHECKASM_ORDER="_\$\$_G,;\.Lj[0-9]+:;,U_[A-Za-z0-9_\$]*_\$\$_G" }
{ Assembly placement proof (store motion ON, at -O4).  The global g is read from
  two routines so it stays memory-resident; the accumulation loop  g:=g+i  would
  normally load-add-store g through memory every iteration.  With -OoSTOREMOTION
  the memory traffic is hoisted out: g is LOADED once before the loop (a
  reference with g as the source operand:  U_..._G,%reg ), the loop body operates
  on a register, and g is STORED once AFTER the loop back-edge (a reference with
  g as the destination:  %reg,U_..._G ).  The CHECKASM_ORDER asserts exactly that
  sequence -- load-of-g, then a loop label, then store-to-g -- in the kept
  assembly.  Its control optstoremotion_placement_disabled_01 shows the opposite
  order (store inside the loop) with the pass off. }
program optstoremotion_placement_01;
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
