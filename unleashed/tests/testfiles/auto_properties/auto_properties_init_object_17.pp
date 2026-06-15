program auto_properties_init_object_17;

{$mode unleashed}

// old-style objects apply initializers through their constructor
type
  TPoint = object
    property X: Integer = 7;
    constructor Init;
  end;

constructor TPoint.Init;
begin
end;

var
  p: TPoint;
begin
  p.Init;
  if p.X <> 7 then halt(1);
end.
