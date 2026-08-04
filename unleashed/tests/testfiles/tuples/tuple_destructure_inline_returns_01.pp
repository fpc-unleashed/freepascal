{$mode unleashed}
program tuple_destructure_inline_returns_01;

uses
  SysUtils;

{ inline var destructuring from tuple returns }

function Pair: (Integer, Integer);
begin
  Result := (10, 20);
end;

function Coords: (a, b: Integer);
begin
  Result := (a: 100, b: 200);
end;

function Triple: (Integer, Integer, Integer);
begin
  Result := (1, 2, 3);
end;

function Mixed: (Integer, String);
begin
  Result := (42, 'hello');
end;

procedure Test;
begin
  var (x, y) := Pair;
  if (x <> 10) or (y <> 20) then Halt(1);

  var (a, b) := Coords;
  if (a <> 100) or (b <> 200) then Halt(2);

  { destructuring with renaming }
  var (xx, yy) := Coords;
  if (xx <> 100) or (yy <> 200) then Halt(3);

  { triple }
  var (u, v, w) := Triple;
  if (u <> 1) or (v <> 2) or (w <> 3) then Halt(4);

  { mixed types }
  var (num, text) := Mixed;
  if (num <> 42) or (text <> 'hello') then Halt(5);
end;

begin
  Test;
  WriteLn('OK');
end.
