{ %FAIL }
{ test with-list duplicate detection: duplicate symbol must be rejected }
{$mode unleashed}

type
  TPoint = record
    x, y: integer;
  end;

var
  r1, r2: TPoint;
begin
  r1.x := 1; r1.y := 2;
  r2.x := 3; r2.y := 4;
  with r1, r2, r1 do
    halt(1);
end.
