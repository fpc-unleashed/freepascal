{ %OPT=-O4 }
{ Negative case: an arm whose right-hand side is NOT a compile-time constant
  (it calls a function) must make -OoSWITCHTABLE bail and keep the classic
  case lowering, still producing correct results.  A second function has a
  hole in its label range (1,2,5 with a gap at 3,4), which must also bail
  (a hole value has to take the else, which a plain range-guarded table cannot
  express) and stay correct.  Halt(nonzero) = failure. }
program optswitchtable_nonconst_01;
{$mode objfpc}{$H+}

function ext(x: longint): longint; noinline;
begin
  ext := x * 11;
end;

function g(x: longint): longint; noinline;
var
  s: longint;
begin
  s := 0;
  case x of
    1: s := 100;
    2: s := ext(x);   { non-constant arm -> not convertible }
    3: s := 300;
  else
    s := -1;
  end;
  g := s;
end;

function h(x: longint): longint; noinline;
var
  s: longint;
begin
  s := 0;
  case x of
    1: s := 10;
    2: s := 20;
    5: s := 50;       { hole at 3,4 -> not convertible }
  else
    s := -9;
  end;
  h := s;
end;

var
  x: longint;
begin
  if g(1) <> 100 then Halt(1);
  if g(2) <> 22  then Halt(2);
  if g(3) <> 300 then Halt(3);
  if g(4) <> -1  then Halt(4);

  for x := -2 to 7 do
    begin
      if x = 1 then
        begin if h(x) <> 10 then Halt(5); end
      else if x = 2 then
        begin if h(x) <> 20 then Halt(6); end
      else if x = 5 then
        begin if h(x) <> 50 then Halt(7); end
      else
        if h(x) <> -9 then Halt(8);
    end;

  Halt(0);
end.
