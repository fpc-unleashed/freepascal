program type_intrinsic_regression_strong_alias_10;

{$mode unleashed}

type
  // strong alias still works exactly as before
  TMyInt = type Integer;
  TOtherInt = type Integer;
  // plain type section also intact
  TPoint = record x, y: Integer; end;

var
  a: TMyInt;
  b: TOtherInt;
  p: TPoint;
begin
  a := TMyInt(10);
  b := TOtherInt(20);
  if a <> 10 then Halt(1);
  if b <> 20 then Halt(2);
  p.x := 1; p.y := 2;
  if p.x + p.y <> 3 then Halt(3);
end.
