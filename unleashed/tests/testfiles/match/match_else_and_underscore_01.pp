{$mode unleashed}
{ match statement: else and _ catch-all }
program match_else_and_underscore_01;

procedure TestElse;
var
  x, r: Integer;
begin
  x := 99;
  r := 0;
  match x of
    1: r := 10;
    2: r := 20;
  else
    r := 999;
  end;
  if r <> 999 then Halt(1);
end;

procedure TestUnderscore;
var
  x, r: Integer;
begin
  x := 42;
  r := 0;
  match x of
    1: r := 10;
    _: r := 100;
  end;
  if r <> 100 then Halt(2);
end;

procedure TestUnderscoreSkipsOnMatch;
var
  x, r: Integer;
begin
  x := 1;
  r := 0;
  match x of
    1: r := 10;
    _: r := 100;
  end;
  if r <> 10 then Halt(3);
end;

begin
  TestElse;
  TestUnderscore;
  TestUnderscoreSkipsOnMatch;
  WriteLn('OK');
end.
