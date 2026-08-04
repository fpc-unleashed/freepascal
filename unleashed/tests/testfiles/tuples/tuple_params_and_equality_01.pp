{$mode unleashed}
program tuple_params_and_equality_01;

uses
  SysUtils;

{ tuple equality + F2/F7: tuple as parameter / argument }

procedure ShowPair(p: (Integer, Integer));
begin
  Write(p._1, ' ', p._2);
end;

function DotProduct(a, b: (Integer, Integer, Integer)): Integer;
begin
  Result := a._1*b._1 + a._2*b._2 + a._3*b._3;
end;

procedure ShowNamed(c: (x, y: Integer));
begin
  Write(c.x, '/', c.y);
end;

var
  p, q: (Integer, Integer);
  n1, n2: (a, b: Integer);
  s1, s2: (Integer, String);
begin
  { equality }
  p := (10, 20);
  q := (10, 20);
  if not (p = q) then Halt(1);
  q := (10, 99);
  if not (p <> q) then Halt(2);
  if p = q then Halt(3);

  n1 := (a: 1, b: 2);
  n2 := (a: 1, b: 2);
  if not (n1 = n2) then Halt(4);
  n2 := (a: 99, b: 2);
  if not (n1 <> n2) then Halt(5);

  s1 := (5, 'hello');
  s2 := (5, 'hello');
  if not (s1 = s2) then Halt(6);
  s2 := (5, 'world');
  if not (s1 <> s2) then Halt(7);

  { pass tuple literal and tuple variable to function }
  ShowPair((1, 2));
  Write(' ');
  ShowPair(p);
  Write(' ');

  if DotProduct((1, 2, 3), (4, 5, 6)) <> 32 then Halt(10);

  ShowNamed((7, 8));
  WriteLn;

  WriteLn('OK');
end.
