{ %OPT="-O4" }
{ -OoVRP observable-behaviour correctness across the folded shapes: for-loop
  counter bounds, mod/and derived ranges, dominating-guard narrowing, and cases
  that must NOT fold.  Every branch's real outcome is cross-checked with Halt so
  a wrong fold (deleting a live arm or keeping a dead one) is caught at runtime.
  Run identically with -O4 and -O4 -OoNOVRP -- the result must match. }
program optvrpfold_runtime_01;
{$mode objfpc}{$H+}

function ext(v: longint): longint; noinline;
begin
  ext := v + ParamCount;   { opaque to the optimizer: ParamCount is runtime }
end;

var
  acc: longint;

procedure counters; noinline;
var
  i, taken: longint;
begin
  taken := 0;
  for i := 0 to 5 do
    begin
      if i > 10 then Halt(11);      { always false }
      if i < 0 then Halt(12);       { always false }
      if i <= 5 then Inc(taken);    { always true }
    end;
  if taken <> 6 then Halt(13);
  for i := 3 downto 0 do            { downto: still [0..3] }
    if (i < 0) or (i > 3) then Halt(14);
end;

procedure derived; noinline;
var
  n, m: longint;
begin
  n := ext(987654) mod 100;
  if (n < -99) or (n > 99) then Halt(21);
  if n >= 1000 then Halt(22);       { folded away, must not run }
  m := ext(987654) and 15;
  if (m < 0) or (m > 15) then Halt(23);
  if m > 15 then Halt(24);          { folded away }
  acc := n + m;
end;

procedure guards(x: longint); noinline;
begin
  if x > 100 then
    begin
      if x <= 100 then Halt(31);    { contradiction with the guard }
      if x < 50 then Halt(32);      { impossible under x>100 }
      Inc(acc);
    end
  else
    begin
      if x > 100 then Halt(33);     { impossible under the else }
      Inc(acc);
    end;
end;

procedure mustnotfold; noinline;
var
  i, a, b: longint;
begin
  a := 0; b := 0;
  for i := 0 to 20 do
    if i > 10 then Inc(a) else Inc(b);
  if a <> 10 then Halt(41);
  if b <> 11 then Halt(42);
end;

begin
  acc := 0;
  counters;
  derived;
  guards(200);
  guards(3);
  mustnotfold;
  { derived: 987654 mod 100 = 54, 987654 and 15 = 6 -> acc = 60; guards add 2 }
  if acc <> 62 then
    Halt(99);
end.
