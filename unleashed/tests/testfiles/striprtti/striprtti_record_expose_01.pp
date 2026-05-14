{ %NORUN }
program striprtti_record_expose_01;

{$mode unleashed}
{$modeswitch striprtti}

type
  // expose works on records, enums, sets, ranges, aliases too
  expose TPoint = record
    x, y: Integer;
  end;

  expose TColor = (cRed, cGreen, cBlue);
  expose TColorSet = set of TColor;
  expose TByteRange = 0..255;
  expose TIntAlias = type Integer;

var
  pt: TPoint;
  c: TColor;
  cs: TColorSet;
  br: TByteRange;
  ia: TIntAlias;
begin
  pt.x := 1;
  pt.y := 2;
  c := cRed;
  cs := [cRed, cBlue];
  br := 42;
  ia := TIntAlias(99);
end.
