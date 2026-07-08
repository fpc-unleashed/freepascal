{ %OPT=-O4 }
{ -OoSWITCHTABLE correctness oracle: a dense constant-assigning case must behave
  identically to the classic lowering across the FULL input range, including
  out-of-range values taking the else part.  Two shapes are exercised: an enum
  map that fully covers its type (no else, no range guard) and an integer map
  over a contiguous sub-range 1..5 with an else, checked for every value in
  -3..9 so the transform's single range guard is proven to partition in-range
  (table) from out-of-range (else) exactly.  Halt(nonzero) = failure. }
program optswitchtable_correct_01;
{$mode objfpc}{$H+}

type
  TColor = (cRed, cGreen, cBlue, cYellow, cCyan);

function colweight(c: TColor): longint; noinline;
var
  w: longint;
begin
  w := -1;
  case c of
    cRed:    w := 10;
    cGreen:  w := 20;
    cBlue:   w := 30;
    cYellow: w := 40;
    cCyan:   w := 50;
  end;
  colweight := w;
end;

function score(x: longint): longint; noinline;
var
  s: longint;
begin
  s := 1234;
  case x of
    1: s := 100;
    2: s := 200;
    3: s := 300;
    4: s := 400;
    5: s := 500;
  else
    s := -7;
  end;
  score := s;
end;

{ reference implementation the optimizer never sees as a table (opaque call in
  each arm defeats recognition), used as an independent oracle }
function opaque(v: longint): longint; noinline;
begin
  opaque := v;
end;

function score_ref(x: longint): longint; noinline;
var
  s: longint;
begin
  s := opaque(1234);
  case x of
    1: s := opaque(100);
    2: s := opaque(200);
    3: s := opaque(300);
    4: s := opaque(400);
    5: s := opaque(500);
  else
    s := opaque(-7);
  end;
  score_ref := s;
end;

var
  c: TColor;
  x: longint;
begin
  { enum map, full type coverage }
  for c := cRed to cCyan do
    if colweight(c) <> (ord(c) + 1) * 10 then
      Halt(1);

  { integer map with else, every value incl out-of-range }
  for x := -3 to 9 do
    begin
      if score(x) <> score_ref(x) then
        Halt(2);
      if (x >= 1) and (x <= 5) then
        begin
          if score(x) <> x * 100 then
            Halt(3);
        end
      else
        if score(x) <> -7 then
          Halt(4);
    end;

  Halt(0);
end.
