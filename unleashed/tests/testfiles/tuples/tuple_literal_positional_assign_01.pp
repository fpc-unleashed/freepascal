{$mode unleashed}
program tuple_literal_positional_assign_01;

uses
  SysUtils;

{ positional tuple literals on RHS of assignment }

function GetPair: (Integer, Integer);
begin
  Result := (100, 200);
end;

function GetMixed: (Integer, String);
begin
  Result := (42, 'hello');
end;

var
  p: (Integer, Integer);
  m: (Integer, String);
  q: (Integer, Integer, Integer);
begin
  p := (10, 20);
  if (p._1 <> 10) or (p._2 <> 20) then Halt(1);

  p := GetPair;
  if (p._1 <> 100) or (p._2 <> 200) then Halt(2);

  m := (42, 'hello');
  if (m._1 <> 42) or (m._2 <> 'hello') then Halt(3);

  m := GetMixed;
  if (m._1 <> 42) or (m._2 <> 'hello') then Halt(4);

  q := (1, 2, 3);
  if (q._1 <> 1) or (q._2 <> 2) or (q._3 <> 3) then Halt(5);

  WriteLn('OK');
end.
