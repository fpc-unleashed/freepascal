{$mode unleashed}
program tuple_literal_named_reorder_01;

uses
  SysUtils;

{ named tuple literals, with arbitrary field order }

function GetCoords: (a, b: Integer);
begin
  Result := (a: 1, b: 2);
end;

function GetReordered: (a, b: Integer);
begin
  Result := (b: 20, a: 10);
end;

var
  c: (a, b: Integer);
begin
  c := GetCoords;
  if (c.a <> 1) or (c.b <> 2) then Halt(1);

  c := GetReordered;
  if (c.a <> 10) or (c.b <> 20) then Halt(2);

  c := (a: 5, b: 15);
  if (c.a <> 5) or (c.b <> 15) then Halt(3);

  c := (b: 99, a: 88);
  if (c.a <> 88) or (c.b <> 99) then Halt(4);

  WriteLn('OK');
end.
