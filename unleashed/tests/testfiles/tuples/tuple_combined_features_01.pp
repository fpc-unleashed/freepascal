{$mode unleashed}
program tuple_combined_features_01;

uses
  SysUtils;

{ multi-assignment, swap, for-in destructuring,
  nested tuples, tuple fields in records, managed types }

function Pair: (Integer, Integer);
begin
  Result := (10, 20);
end;

function Coords: (a, b: Integer);
begin
  Result := (a: 100, b: 200);
end;

function NestedPos: (Integer, (String, Integer));
begin
  Result._1 := 1;
  Result._2._1 := 'hi';
  Result._2._2 := 99;
end;

type
  TItem = record
    id: Integer;
    pt: (x, y: Integer);
  end;

var
  x, y: Integer;
  a, b: Integer;
  n: Integer;
  s: String;
  arr: array of (Integer, String);
  arrsum: Integer;
  strcat: String;
  it: TItem;
  np: (Integer, (String, Integer));
begin
  { multi-assignment to existing vars }
  (x, y) := Pair;
  if (x <> 10) or (y <> 20) then Halt(1);

  (a, b) := Coords;
  if (a <> 100) or (b <> 200) then Halt(2);

  { swap via destructuring }
  x := 1; y := 2;
  (x, y) := (y, x);
  if (x <> 2) or (y <> 1) then Halt(3);

  { for-in destructuring }
  arr := [(1, 'aa'), (2, 'bb'), (3, 'cc')];
  arrsum := 0;
  strcat := '';
  for var (nn, ss) in arr do
    begin
      arrsum := arrsum + nn;
      strcat := strcat + ss;
    end;
  if arrsum <> 6 then Halt(4);
  if strcat <> 'aabbcc' then Halt(5);

  { nested tuples }
  np := NestedPos;
  if (np._1 <> 1) or (np._2._1 <> 'hi') or (np._2._2 <> 99) then Halt(6);

  np := (5, ('zz', 77));
  if (np._1 <> 5) or (np._2._1 <> 'zz') or (np._2._2 <> 77) then Halt(7);

  { tuple as record field }
  it.id := 42;
  it.pt.x := 9;
  it.pt.y := 8;
  if (it.id <> 42) or (it.pt.x <> 9) or (it.pt.y <> 8) then Halt(8);

  it.pt := (x: 111, y: 222);
  if (it.pt.x <> 111) or (it.pt.y <> 222) then Halt(9);

  it.pt := (1, 2);
  if (it.pt.x <> 1) or (it.pt.y <> 2) then Halt(10);

  { managed types (String) in tuple }
  (n, s) := (42, 'hello');
  if (n <> 42) or (s <> 'hello') then Halt(11);

  WriteLn('OK');
end.
