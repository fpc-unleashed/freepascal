{ %OPT="-O2 -OoREFELIDE" }
{ -OoREFELIDE managed refcount elision: runtime correctness / no-corruption.
  Every string is built dynamically (Concat / IntToStr / SetLength) so it lives
  on the heap with a real reference count -- a wrong incref/decref elision would
  free a buffer early and corrupt the contents or double-free (crash) over the
  many iterations below.  Halt(N) pinpoints the failing assertion.

  Covers the shapes the pass ACCEPTS (borrow from a value parameter, borrow from
  a single-assignment local), the shapes it must DECLINE (source reassigned,
  destination reassigned, destination UniqueString'd / passed by var), and the
  ALIASING hazard: a value-parameter source stays alive for the whole call
  through its entry incref even when a global that aliases it is cleared. }
program optrefelide_correct_01;
{$mode objfpc}{$H+}
uses sysutils;

var g: ansistring;

procedure Fail(n: integer);
begin
  Halt(n);
end;

{ ACCEPT: borrow from value parameter, only read }
function BorrowVP(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  BorrowVP := tmp + '#';
end;

{ ACCEPT: borrow from a single-assignment local }
function BorrowLocal(n: integer): ansistring; noinline;
var a, b: ansistring;
begin
  a := 'v' + IntToStr(n);
  b := a;
  BorrowLocal := b;
end;

{ ALIASING: v aliases global g; clearing g mid-call must NOT free v's buffer
  (the value parameter holds its own reference via the entry incref). tmp
  borrows v and is read AFTER g is cleared. }
function BorrowAliasClear(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  g := '';            { would drop the buffer if v didn't own a reference }
  BorrowAliasClear := tmp + '@';
end;

{ DECLINE: destination reassigned (must keep its own refcount) }
function NoElideReassign(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  tmp := tmp + tmp;   { second def -> not a borrow }
  NoElideReassign := tmp;
end;

{ DECLINE: destination address taken via UniqueString }
function NoElideUnique(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  UniqueString(tmp);
  tmp[1] := 'Z';
  NoElideUnique := tmp;
end;

var
  i: integer;
  s, want: ansistring;
begin
  for i := 1 to 20000 do
  begin
    s := BorrowVP('x' + IntToStr(i));
    if s <> 'x' + IntToStr(i) + '#' then Fail(1);

    s := BorrowLocal(i);
    if s <> 'v' + IntToStr(i) then Fail(2);

    g := 'g' + IntToStr(i);
    s := BorrowAliasClear(g);
    if s <> 'g' + IntToStr(i) + '@' then Fail(3);
    if g <> '' then Fail(4);

    s := NoElideReassign('r' + IntToStr(i));
    want := 'r' + IntToStr(i);
    if s <> want + want then Fail(5);

    s := NoElideUnique('abc');
    if s <> 'Zbc' then Fail(6);
  end;
  { fall through -> exit 0 = pass }
end.
