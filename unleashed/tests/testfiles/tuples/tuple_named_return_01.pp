{$mode unleashed}
program tuple_named_return_01;

uses
  SysUtils;

{ named tuple as return type, accessed via user-chosen field names }

function Coords: (a, b: Integer);
begin
  Result.a := 5;
  Result.b := 15;
end;

function MultiGroup: (x: Integer; y: String);
begin
  Result.x := 42;
  Result.y := 'hi';
end;

function ThreeGroups: (a, b: Integer; s: String; f: Double);
begin
  Result.a := 1;
  Result.b := 2;
  Result.s := 'name';
  Result.f := 3.5;
end;

var
  c: (a, b: Integer);
  m: (x: Integer; y: String);
  t: (a, b: Integer; s: String; f: Double);
begin
  c := Coords;
  if (c.a <> 5) or (c.b <> 15) then Halt(1);

  m := MultiGroup;
  if (m.x <> 42) or (m.y <> 'hi') then Halt(2);

  t := ThreeGroups;
  if (t.a <> 1) or (t.b <> 2) or (t.s <> 'name') or (t.f <> 3.5) then Halt(3);

  WriteLn('OK');
end.
