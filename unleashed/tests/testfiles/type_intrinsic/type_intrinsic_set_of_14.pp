program type_intrinsic_set_of_14;

{$mode unleashed}

type
  TColor = (cRed, cGreen, cBlue);

var
  c: TColor;
  s: set of Type(c);
begin
  c := cRed;
  s := [cRed, cBlue];
  if not (cRed in s) then Halt(1);
  if cGreen in s then Halt(2);
  if not (cBlue in s) then Halt(3);
end.
