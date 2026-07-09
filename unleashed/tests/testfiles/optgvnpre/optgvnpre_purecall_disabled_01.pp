{ %OPT="-O4 -OoNOGVNPRE" }
{ Disabled-switch control for optgvnpre_purecall_01: the SAME kernels compiled
  with GVN-PRE explicitly OFF must still produce the correct results, proving the
  test sources are valid independently of the pass so any behaviour change is
  attributable to the pure-call value numbering alone. Halt(nonzero)=failure. }
program optgvnpre_purecall_disabled_01;
{$mode objfpc}{$H+}

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

function cst(x: longint): longint;
begin
  cst := x * x - 3 * x + 1;
end;

function pur(x: longint): longint;
begin
  pur := x * x + g;
end;

function redund(a: longint): longint; noinline;
var t, r: longint;
begin
  t := cst(a);
  r := t + cst(a) + cst(a);
  redund := r;
end;

function redund_ref(a: longint): longint;
var e: longint;
begin
  e := cst(a);
  redund_ref := e + e + e;
end;

function partial(a: longint; c: boolean): longint; noinline;
var r: longint;
begin
  if c then r := cst(a) + 10 else r := cst(a) - 10;
  partial := r + cst(a);
end;

function partial_ref(a: longint; c: boolean): longint;
var e, r: longint;
begin
  e := cst(a);
  if c then r := e + 10 else r := e - 10;
  partial_ref := r + e;
end;

function killarg(a: longint): longint; noinline;
var x, y: longint;
begin
  x := cst(a);
  a := a + 4;
  y := cst(a);
  killarg := x * 1000 + y;
end;

function killarg_ref(a: longint): longint;
var x, y: longint;
begin
  x := cst(a);
  a := a + 4;
  y := cst(a);
  killarg_ref := x * 1000 + y;
end;

function killglobal(a: longint): longint; noinline;
var x, y: longint;
begin
  x := pur(a);
  g := g + 100;
  y := pur(a);
  killglobal := x * 100000 + y;
end;

var
  a: longint;
  c: boolean;
begin
  fails := 0;
  g := 5;
  for a := -6 to 6 do
    begin
      chk(redund(a), redund_ref(a), 'redund');
      chk(killarg(a), killarg_ref(a), 'killarg');
      for c := false to true do
        chk(partial(a, c), partial_ref(a, c), 'partial');
      g := 5;
      chk(killglobal(a), (a*a + 5) * 100000 + (a*a + 105), 'killglobal');
    end;
  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
