{ %OPT="-O3 -OoPURE -Oodeadstore" }
{ -OoPURE consumer: the extended (record-field / static-array-element) dead-store
  elimination treats a call to a routine proven CONST or PURE by -OoPURE as a
  non-barrier, so a store overwritten before any observable read survives the
  intervening call and the earlier (dead) store is removed.

  Soundness is asymmetric and exercised here:
    * a CONST call reads and writes no memory      -> full non-barrier;
    * a PURE call writes nothing but may READ global state, so a dead store to a
      globally reachable slot (a static var) is KEPT (the call could observe it)
      while a store to a non-address-taken local is still removed;
    * an IMPURE call stays a hard barrier.

  DSE must be observationally transparent regardless of which stores it removes:
  every kernel is checked against an independently computed reference and any
  mismatch halts with a nonzero code. All arrays are fully initialised so the
  result is deterministic. }
program optpure_dse_01;
{$mode objfpc}

type
  TArr = array[0..3] of longint;

var
  g   : longint;
  sg  : TArr;
  fails : longint;

{ CONST: result depends only on by-value args, reads/writes nothing }
function cpure(x: longint): longint; noinline;
begin cpure := x * x + 1; end;

{ PURE: reads the global g but writes nothing }
function preads(x: longint): longint; noinline;
begin preads := g + x; end;

{ impure: writes the global g }
procedure impure(x: longint); noinline;
begin g := g + x; end;

{ dead store (a[0]:=111) across a CONST call -> removed, result unchanged }
function wconst(v: longint): longint; noinline;
var a: TArr; t: longint;
begin
  a[0] := 111; a[1] := 11; a[2] := 12; a[3] := 13;
  t := cpure(v);
  a[0] := 222;
  wconst := a[0] + a[1] + a[2] + a[3] + t;
end;

{ dead store (a[0]:=333) across an IMPURE call -> KEPT, result unchanged }
function wimpure(v: longint): longint; noinline;
var a: TArr;
begin
  a[0] := 333; a[1] := 21; a[2] := 22; a[3] := 23;
  impure(v);
  a[0] := 444;
  wimpure := a[0] + a[1] + a[2] + a[3];
end;

{ dead store (a[0]:=555) to a LOCAL across a PURE (reads-global) call -> removed }
function wpurelocal(v: longint): longint; noinline;
var a: TArr; t: longint;
begin
  a[0] := 555; a[1] := 31; a[2] := 32; a[3] := 33;
  t := preads(v);
  a[0] := 666;
  wpurelocal := a[0] + a[1] + a[2] + a[3] + t;
end;

{ dead store (sg[0]:=777) to a STATIC var across a PURE call -> KEPT }
function wpurestatic(v: longint): longint; noinline;
var t: longint;
begin
  sg[0] := 777; sg[1] := 41; sg[2] := 42; sg[3] := 43;
  t := preads(v);
  sg[0] := 888;
  wpurestatic := sg[0] + sg[1] + sg[2] + sg[3] + t;
end;

procedure check(got, want: longint; const what: string);
begin
  if got <> want then
    begin
      writeln('FAIL ', what, ': got ', got, ' want ', want);
      inc(fails);
    end;
end;

begin
  g := 0;
  fails := 0;

  { wconst(2): a[0]=222, +11+12+13 + cpure(2)=5  = 263 }
  check(wconst(2), 222 + 11 + 12 + 13 + (2*2+1), 'wconst');

  { impure(3) runs here -> g becomes 3 }
  { wimpure(3): a[0]=444 +21+22+23 = 510, g:=3 }
  check(wimpure(3), 444 + 21 + 22 + 23, 'wimpure');

  { wpurelocal(4): a[0]=666 +31+32+33 + preads(4)=g+4=7 = 769 }
  check(wpurelocal(4), 666 + 31 + 32 + 33 + (3 + 4), 'wpurelocal');

  { wpurestatic(5): sg[0]=888 +41+42+43 + preads(5)=g+5=8 = 1022 }
  check(wpurestatic(5), 888 + 41 + 42 + 43 + (3 + 5), 'wpurestatic');

  if fails <> 0 then
    Halt(1);
  writeln('ok');
end.
