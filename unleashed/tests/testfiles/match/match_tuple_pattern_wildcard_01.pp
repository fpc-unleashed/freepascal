{$mode unleashed}
{ match: wildcard _ in tuple patterns }
program match_tuple_pattern_wildcard_01;

function MakePoint(a, b: Integer): (Integer, Integer);
begin
  Result := (a, b);
end;

procedure TestExactTuple;
var
  p: (Integer, Integer);
  r: Integer;
begin
  p := MakePoint(3, 7);
  r := 0;
  match p of
    (3, 7): r := 1;
    (0, 0): r := 2;
    _:      r := 9;
  end;
  if r <> 1 then Halt(1);
end;

procedure TestWildcardSecond;
var
  p: (Integer, Integer);
  r: Integer;
begin
  p := MakePoint(0, 42);
  r := 0;
  match p of
    (0, _): r := 1;
    (_, 0): r := 2;
    _:      r := 9;
  end;
  if r <> 1 then Halt(2);
end;

procedure TestWildcardFirst;
var
  p: (Integer, Integer);
  r: Integer;
begin
  p := MakePoint(99, 0);
  r := 0;
  match p of
    (0, _): r := 1;
    (_, 0): r := 2;
    _:      r := 9;
  end;
  if r <> 2 then Halt(3);
end;

procedure TestAllWildcard;
var
  p: (Integer, Integer);
  r: Integer;
begin
  p := MakePoint(5, 5);
  r := 0;
  match p of
    (0, 0): r := 1;
    (_, _): r := 2;
  end;
  if r <> 2 then Halt(4);
end;

begin
  TestExactTuple;
  TestWildcardSecond;
  TestWildcardFirst;
  TestAllWildcard;
  WriteLn('OK');
end.
