{ test with-list duplicate detection: valid cases must compile and run }
{$mode unleashed}

type
  TPoint = record
    x, y: integer;
  end;

var
  r1, r2, r3: TPoint;
  sum: integer;
begin
  r1.x := 1; r1.y := 2;
  r2.x := 3; r2.y := 4;
  r3.x := 5; r3.y := 6;

  { distinct symbols are fine }
  sum := 0;
  with r1, r2, r3 do
    sum := x + y;
  if sum <> 11 then
    halt(1);

  { nested with is not a flat list - same symbol allowed }
  with r1 do
    with r1 do
      if x <> 1 then
        halt(2);
end.
