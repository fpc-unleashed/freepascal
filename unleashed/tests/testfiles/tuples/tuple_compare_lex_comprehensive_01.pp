{$mode unleashed}
program tuple_compare_lex_comprehensive_01;

uses
  SysUtils;

{ Comprehensive test of lexicographic comparisons and all
  equality ops on tuples }

function SortTuples(a, b, c: (Integer, Integer)): (Integer, Integer, Integer);
var
  tmp: (Integer, Integer);
  order: (Integer, Integer, Integer);
begin
  { simple bubble sort of 3 tuples by <, return indices 0..2 }
  order := (0, 1, 2);
  if a > b then
    begin
      tmp := a; a := b; b := tmp;
      order := (1, 0, 2);
    end;
  if b > c then
    begin
      tmp := b; b := c; c := tmp;
      if order._2 = 1 then order := (order._1, 2, 1)
      else order := (order._1, order._3, 1);
    end;
  if a > b then
    begin
      tmp := a; a := b; b := tmp;
      order := (order._2, order._1, order._3);
    end;
  Result := order;
end;

var
  p, q, r: (Integer, Integer);
begin
  { equality basics }
  p := (1, 2); q := (1, 2);
  if not (p = q) then Halt(1);
  if p <> q then Halt(2);

  { order }
  p := (1, 1); q := (1, 2);
  if not (p < q) then Halt(3);
  if not (p <= q) then Halt(4);
  if p >= q then Halt(5);
  if p > q then Halt(6);

  { equal under <= >= }
  p := (5, 5); q := (5, 5);
  if not (p <= q) then Halt(7);
  if not (p >= q) then Halt(8);
  if p < q then Halt(9);
  if p > q then Halt(10);

  { strictly greater }
  p := (3, 0); q := (2, 9);
  if not (p > q) then Halt(11);
  if not (q < p) then Halt(12);

  { cross-shape named vs positional via structural compat }
  r := (3, 0);
  if not (p = r) then Halt(13);

  WriteLn('OK');
end.
