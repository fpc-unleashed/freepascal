{$mode unleashed}
{ match all: fallthrough mode and leave }
program match_all_fallthrough_and_leave_01;

procedure TestFallthrough;
var
  x, r: Integer;
begin
  x := 5;
  r := 0;
  match all x of
    5: r := r + 1;
    5: r := r + 10;
    3: r := r + 100;
  end;
  { both x=5 branches fire, x=3 does not }
  if r <> 11 then Halt(1);
end;

procedure TestFallthroughCatchAll;
var
  x, r: Integer;
begin
  x := 1;
  r := 0;
  match all x of
    1: r := r + 1;
    2: r := r + 10;
    _: r := r + 100;
  end;
  { x=1 matches, x=2 does not, _ always matches }
  if r <> 101 then Halt(2);
end;

procedure TestLeave;
var
  x, r: Integer;
begin
  x := 5;
  r := 0;
  match all x of
    5: begin r := r + 1; leave; end;
    5: r := r + 10;
    _: r := r + 100;
  end;
  { leave exits after first branch }
  if r <> 1 then Halt(3);
end;

begin
  TestFallthrough;
  TestFallthroughCatchAll;
  TestLeave;
  WriteLn('OK');
end.
