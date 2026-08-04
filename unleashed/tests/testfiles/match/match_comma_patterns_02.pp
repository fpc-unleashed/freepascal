{$mode unleashed}
{ match: comma-separated patterns (OR) }
program match_comma_patterns_02;

procedure TestComma;
var
  x, r: Integer;
begin
  x := 3;
  r := 0;
  match x of
    1, 2, 3: r := 10;
    4, 5, 6: r := 20;
    _:       r := 99;
  end;
  if r <> 10 then Halt(1);
end;

procedure TestCommaSecondGroup;
var
  x, r: Integer;
begin
  x := 5;
  r := 0;
  match x of
    1, 2, 3: r := 10;
    4, 5, 6: r := 20;
    _:       r := 99;
  end;
  if r <> 20 then Halt(2);
end;

procedure TestCommaNoMatch;
var
  x, r: Integer;
begin
  x := 100;
  r := 0;
  match x of
    1, 2, 3: r := 10;
    4, 5, 6: r := 20;
    _:       r := 99;
  end;
  if r <> 99 then Halt(3);
end;

begin
  TestComma;
  TestCommaSecondGroup;
  TestCommaNoMatch;
  WriteLn('OK');
end.
