program record_helper_01;

{$mode unleashed}

type
  TPoint = record
    x, y: Integer;
  end;

  TPointHelper = record helper for TPoint
    function Magnitude: Integer;
    procedure Translate(dx, dy: Integer);
  end;

function TPointHelper.Magnitude: Integer;
begin
  Result := Self.x * Self.x + Self.y * Self.y;
end;

procedure TPointHelper.Translate(dx, dy: Integer);
begin
  Self.x := Self.x + dx;
  Self.y := Self.y + dy;
end;

var
  p: TPoint;

begin
  p.x := 3;
  p.y := 4;
  if p.Magnitude <> 25 then halt(1);
  p.Translate(10, 20);
  if p.x <> 13 then halt(2);
  if p.y <> 24 then halt(3);
end.
