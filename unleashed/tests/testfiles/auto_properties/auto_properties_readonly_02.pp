program auto_properties_readonly_02;

{$mode unleashed}

type
  TPoint = class
    property X: Integer; readonly;   // auto: read FX only
    constructor Create(aX: Integer);
  end;

constructor TPoint.Create(aX: Integer);
begin
  FX := aX;        // backing field is writable from inside the class
end;

var
  p: TPoint;
begin
  p := TPoint.Create(99);
  if p.X <> 99 then halt(1);
  p.Free;
end.
