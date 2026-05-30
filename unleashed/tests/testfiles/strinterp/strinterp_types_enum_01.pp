program strinterp_types_enum_01;

{$mode unleashed}

type
  TColor = (cRed, cGreen, cBlue);

var
  col: TColor;
  s: string;
begin
  col := cRed;
  s := $'{col}';
  if s <> 'cRed' then halt(1);

  col := cBlue;
  s := $'color is {col}';
  if s <> 'color is cBlue' then halt(2);
end.
