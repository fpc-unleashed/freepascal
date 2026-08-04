{$mode unleashed}
{ match without of: condition-based matching }
program match_condition_forms_01;

procedure TestFirstMatch;
var
  x, r: Integer;
begin
  x := 50;
  r := 0;
  match
    x > 100: r := 1;
    x > 10:  r := 2;
    x > 0:   r := 3;
    _:       r := 4;
  end;
  { first-match: x=50 matches x>10 first }
  if r <> 2 then Halt(1);
end;

procedure TestFallthrough;
var
  x, r: Integer;
begin
  x := 50;
  r := 0;
  match all
    x > 100: r := r + 1;
    x > 10:  r := r + 10;
    x > 0:   r := r + 100;
  end;
  { x=50: x>10 and x>0 match }
  if r <> 110 then Halt(2);
end;

procedure TestCatchAll;
var
  x, r: Integer;
begin
  x := -5;
  r := 0;
  match
    x > 0: r := 1;
    _:     r := 99;
  end;
  if r <> 99 then Halt(3);
end;

begin
  TestFirstMatch;
  TestFallthrough;
  TestCatchAll;
  WriteLn('OK');
end.
