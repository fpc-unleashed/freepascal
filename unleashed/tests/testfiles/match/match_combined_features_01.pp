{$mode unleashed}
{ match statement: combined features demo }
program match_combined_features_01;

function MakeCoords(a, b: Integer): (Integer, Integer);
begin
  Result := (a, b);
end;

procedure DemoSubjectMatch;
var
  direction: Integer;
  s: String;
begin
  direction := 2;
  s := match direction of
    0: 'north';
    1: 'east';
    2: 'south';
    3: 'west';
    _: 'unknown';
  end;
  if s <> 'south' then Halt(1);
end;

procedure DemoConditionMatch;
var
  x: Integer;
  r: Integer;
begin
  x := 50;
  r := 0;
  match
    x > 100: r := 1;
    x > 10:  r := 2;
    x > 0:   r := 3;
    _:       r := 4;
  end;
  if r <> 2 then Halt(2);
end;

procedure DemoTupleWildcard;
var
  p: (Integer, Integer);
  r: Integer;
begin
  p := MakeCoords(0, 5);
  r := 0;
  match p of
    (0, 0): r := 1;
    (0, _): r := 2;
    (_, 0): r := 3;
    _:      r := 4;
  end;
  if r <> 2 then Halt(3);
end;

procedure DemoFallthrough;
var
  x, r: Integer;
begin
  x := 5;
  r := 0;
  match all x of
    5: r := r + 1;
    5: r := r + 10;
    3: r := r + 100;
    _: r := r + 1000;
  end;
  if r <> 1011 then Halt(4);
end;

procedure DemoCommaPatterns;
var
  x: Integer;
  s: String;
begin
  x := 3;
  s := match x of
    1, 2, 3: 'small';
    4, 5, 6: 'medium';
    _:       'big';
  end;
  if s <> 'small' then Halt(5);
end;

begin
  DemoSubjectMatch;
  DemoConditionMatch;
  DemoTupleWildcard;
  DemoFallthrough;
  DemoCommaPatterns;
  WriteLn('OK');
end.
