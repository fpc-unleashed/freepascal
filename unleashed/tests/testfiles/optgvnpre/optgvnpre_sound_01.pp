{ %OPT=-O4 -OoGVNPRE }
{ -OoGVNPRE soundness: the cases where a redundant-looking recomputation must
  NOT be replaced by an earlier value, exactly the traps a naive value-numbering
  pass falls into.  Each returns a value that differs depending on whether the
  reuse was (wrongly) applied, and is checked against the correct semantics.
    1. an intervening assignment to an operand kills the expression;
    2. a store through a (possibly aliasing) pointer kills memory reads;
    3. a call kills memory reads (globals could be modified);
    4. the conditionally-evaluated right operand of a short-circuit and/or is
       never treated as unconditionally available -- reusing p^ from  p^>0  when
       p may be nil would dereference nil.
  Halt(nonzero) = failure. }
program optgvnpre_sound_01;
{$mode objfpc}{$H+}

type
  plongint = ^longint;

var
  fails: longint;
  g: longint;

procedure chk(got, want: longint; const msg: string);
begin
  if got <> want then
    begin
      writeln('FAIL ', msg, ' got=', got, ' want=', want);
      inc(fails);
    end;
end;

{ 1. intervening assignment to a kills a*b }
function invalidate(a, b: longint): longint; noinline;
var x, y: longint;
begin
  x := a * b + 1;
  a := a + 5;
  y := a * b + 2;         { must use the NEW a }
  invalidate := x * 1000 + y;
end;

{ 2. store through q may alias p^ }
function ptrstore(p, q: plongint): longint; noinline;
var x, y: longint;
begin
  x := p^ + 7;
  q^ := 100;
  y := p^ + 9;            { must reload p^ }
  ptrstore := x * 1000 + y;
end;

function bump: longint; noinline;
begin
  g := g + 1000;
  bump := 0;
end;

{ 3. a call between two loads of a global kills the first load's value }
function callkill: longint; noinline;
var x, y: longint;
begin
  x := g + 1;
  x := x + bump;          { call may change g }
  y := g + 2;             { must reload g }
  callkill := x * 1000000 + y;
end;

{ 4. short-circuit: p^ appears only in the guarded rhs and in the guarded body }
function shortcirc(p: plongint): longint; noinline;
begin
  shortcirc := -1;
  if (p <> nil) and (p^ > 0) then
    shortcirc := p^ + p^
  else
    shortcirc := 0;
end;

var
  v1, v2: longint;
begin
  fails := 0;

  { a=3,b=4: x=13; a becomes 8; y=8*4+2=34 }
  chk(invalidate(3, 4), 13 * 1000 + 34, 'invalidate');

  v1 := 5; v2 := 6;
  chk(ptrstore(@v1, @v1), (5 + 7) * 1000 + (100 + 9), 'ptrstore-alias');
  v1 := 5; v2 := 6;
  chk(ptrstore(@v1, @v2), (5 + 7) * 1000 + (5 + 9), 'ptrstore-noalias');

  g := 10;
  { x = 11 + 0 = 11 ; bump makes g=1010 ; y = 1012 }
  chk(callkill, 11 * 1000000 + 1012, 'callkill');

  chk(shortcirc(nil), 0, 'shortcirc-nil');
  v1 := 42;
  chk(shortcirc(@v1), 84, 'shortcirc-val');
  v1 := -7;
  chk(shortcirc(@v1), 0, 'shortcirc-neg');

  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
