{ %OPT="-O2" }
{ Control for optrefelide_correct_01: the IDENTICAL program compiled WITHOUT
  -OoREFELIDE (the pass is opt-in, so plain -O2 leaves it off) must produce the
  same observable behaviour -- proving the elision is behaviour-preserving. }
program optrefelide_disabled_01;
{$mode objfpc}{$H+}
uses sysutils;

var g: ansistring;

procedure Fail(n: integer);
begin
  Halt(n);
end;

function BorrowVP(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  BorrowVP := tmp + '#';
end;

function BorrowLocal(n: integer): ansistring; noinline;
var a, b: ansistring;
begin
  a := 'v' + IntToStr(n);
  b := a;
  BorrowLocal := b;
end;

function BorrowAliasClear(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  g := '';
  BorrowAliasClear := tmp + '@';
end;

function NoElideReassign(v: ansistring): ansistring; noinline;
var tmp: ansistring;
begin
  tmp := v;
  tmp := tmp + tmp;
  NoElideReassign := tmp;
end;

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
end.
