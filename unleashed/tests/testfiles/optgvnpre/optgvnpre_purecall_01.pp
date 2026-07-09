{ %OPT="-O4 -OoPURE -OoGVNPRE" }
{ -OoGVNPRE consumes the -OoPURE verdict: two structurally identical calls to a
  routine proven PURE (reads global state but never writes it, no I/O, cannot
  raise/trap), with the same arguments and the pure-read memory unchanged in
  between, are commoned to a single call whose value is reused from a temp. This
  must be observationally identical to calling the routine every time. Each
  kernel is checked against an independently-written reference over a cross
  product of inputs; the soundness kernels additionally mutate an argument or the
  global the pure routine reads between the two calls, so a value-number that
  wrongly reuses a stale result (past a kill) is caught. Halt(nonzero)=failure. }
program optgvnpre_purecall_01;
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

{ const: result depends only on the by-value parameter }
function cst(x: longint): longint;
begin
  cst := x * x - 3 * x + 1;
end;

{ pure: also reads a global, still no writes / side effects }
function pur(x: longint): longint;
begin
  pur := x * x + g;
end;

{ --- cross-statement full redundancy of a const call --------------------- }
function redund(a: longint): longint; noinline;
var t, r: longint;
begin
  t := cst(a);
  r := t + cst(a) + cst(a);   { the 2nd and 3rd cst(a) are redundant }
  redund := r;
end;

function redund_ref(a: longint): longint;
var e: longint;
begin
  e := cst(a);
  redund_ref := e + e + e;
end;

{ --- partial redundancy across a rejoining if ---------------------------- }
function partial(a: longint; c: boolean): longint; noinline;
var r: longint;
begin
  if c then
    r := cst(a) + 10
  else
    r := cst(a) - 10;
  partial := r + cst(a);       { available on both arms }
end;

function partial_ref(a: longint; c: boolean): longint;
var e, r: longint;
begin
  e := cst(a);
  if c then r := e + 10 else r := e - 10;
  partial_ref := r + e;
end;

{ --- SOUND: an intervening write to the argument kills the value --------- }
function killarg(a: longint): longint; noinline;
var x, y: longint;
begin
  x := cst(a);
  a := a + 4;
  y := cst(a);                 { must use the NEW a, not reuse x }
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

{ --- SOUND: a store to the global a PURE routine reads kills its value --- }
function killglobal(a: longint): longint; noinline;
var x, y: longint;
begin
  x := pur(a);                 { reads g }
  g := g + 100;                { pur reads g -> the value must change }
  y := pur(a);                 { must recompute with the NEW g, not reuse x }
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
      chk(redund(a), redund_ref(a), 'redund');       { cst: no global }
      chk(killarg(a), killarg_ref(a), 'killarg');    { cst: no global }
      for c := false to true do
        chk(partial(a, c), partial_ref(a, c), 'partial');
      { killglobal mutates g by +100; reset to a known value each call so the
        closed-form reference is deterministic }
      g := 5;
      chk(killglobal(a), (a*a + 5) * 100000 + (a*a + 105), 'killglobal');
    end;
  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
