program zeroinit_basic_record_02;

{$mode unleashed}

type
  TPoint = record
    x, y, z: LongInt;
  end;

procedure DirtyStack;
var
  p: TPoint;
begin
  p.x := 100;
  p.y := 200;
  p.z := 300;
  if p.x+p.y+p.z = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
var
  p: TPoint;
begin
  if p.x <> 0 then halt(1);
  if p.y <> 0 then halt(2);
  if p.z <> 0 then halt(3);
end;

begin
  DirtyStack;
  CheckZero;
end.
