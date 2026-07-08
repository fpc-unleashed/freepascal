{ %OPT=-O4 }
{ SRA is an ENABLER: once a non-escaping record's fields become scalar temps,
  constant propagation and dead-store elimination fold a record built entirely
  from constants down to a single constant, and dead field stores disappear.
  Here folded() builds a record from compile-time constants and returns a
  derived value; the result must equal the hand-computed constant.  (Manual
  -al inspection confirms the field temps are register/immediate and the record
  never touches the stack; see the pass commit message.) }
program sra_constprop_01;
{$mode objfpc}{$H+}

type
  TCfg = record a, b, c: longint; f: double; end;

function folded: longint;
var c: TCfg; t: double;
begin
  c.a := 3;
  c.b := 4;
  c.c := c.a * c.b + 5;      { 17 }
  c.f := c.a + c.b + c.c;    { 24.0 }
  t := c.f * 2.0;            { 48.0 }
  folded := c.c + Trunc(t);  { 17 + 48 = 65 }
end;

{ dead field store: d.y is written twice, first store is dead once scalarised }
function deadstore(a: longint): longint;
var d: TCfg;
begin
  d.a := a;
  d.b := 999;      { dead: overwritten before any read }
  d.b := a + 1;
  deadstore := d.a + d.b;
end;

begin
  if folded <> 65 then Halt(1);
  if deadstore(10) <> 10 + 11 then Halt(2);
end.
