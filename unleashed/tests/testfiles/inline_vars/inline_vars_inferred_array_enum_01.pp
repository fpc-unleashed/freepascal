program inline_vars_inferred_array_enum_01;
{$mode unleashed}

type
  TColor = (cRed, cGreen, cBlue, cYellow);

begin
  var a := [cRed, cBlue, cYellow, cGreen];
  if Length(a) <> 4 then halt(1);
  if SizeOf(a[0]) <> SizeOf(TColor) then halt(2);
  if a[0] <> cRed then halt(3);
  if a[1] <> cBlue then halt(4);
  if a[2] <> cYellow then halt(5);
  if a[3] <> cGreen then halt(6);
  // element compatible with TColor: assignment-compat check
  var c: TColor;
  c := a[0];
  if c <> cRed then halt(7);
end.
