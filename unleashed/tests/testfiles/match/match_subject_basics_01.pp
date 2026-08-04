{$mode unleashed}
{ match statement: basic first-match with ordinal and string subjects }
program match_subject_basics_01;

procedure TestOrdinal;
var
  x: Integer;
  r: Integer;
begin
  x := 2;
  r := 0;
  match x of
    1: r := 10;
    2: r := 20;
    3: r := 30;
  end;
  if r <> 20 then Halt(1);
end;

procedure TestString;
var
  s: String;
  r: Integer;
begin
  s := 'hello';
  r := 0;
  match s of
    'world': r := 1;
    'hello': r := 2;
    'foo':   r := 3;
  end;
  if r <> 2 then Halt(2);
end;

procedure TestFirstMatch;
var
  x: Integer;
  r: Integer;
begin
  { first-match: only first matching branch executes }
  x := 5;
  r := 0;
  match x of
    5: r := r + 1;
    5: r := r + 10;
  end;
  if r <> 1 then Halt(3);
end;

begin
  TestOrdinal;
  TestString;
  TestFirstMatch;
  WriteLn('OK');
end.
