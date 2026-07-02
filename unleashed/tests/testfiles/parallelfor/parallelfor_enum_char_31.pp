program parallelfor_enum_char_31;
{$mode unleashed}
uses SysUtils;
// enum and char loop variables: the dispatch runs on ordinals and converts
// back, so every value is visited exactly once
type TColor = (cRed, cGreen, cBlue, cYellow, cBlack);
var seen: array[TColor] of Integer; c: TColor; n: Integer;
begin
  for c := Low(TColor) to High(TColor) do seen[c] := 0;
  for parallel var e := Low(TColor) to High(TColor) do
    InterlockedIncrement(seen[e]);
  for c := Low(TColor) to High(TColor) do
    if seen[c] <> 1 then halt(1);
  n := 0;
  for parallel var ch := 'a' to 'z' do InterlockedIncrement(n);
  if n <> 26 then halt(2);
end.
