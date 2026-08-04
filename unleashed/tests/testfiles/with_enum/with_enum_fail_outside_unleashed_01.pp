{ %FAIL }
{ `with EnumType do` must NOT work outside mode unleashed }
{$mode objfpc}
{$scopedenums on}

type
  TColor = (red, green, blue);

var
  s: set of TColor;
begin
  with TColor do
    s := [red];
end.
