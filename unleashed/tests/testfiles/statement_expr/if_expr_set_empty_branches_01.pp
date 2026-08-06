program if_expr_set_empty_branches_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

var
  s: TShades;
  flag: boolean;
begin
  // an empty constructor in every branch still takes the set type
  s := [shLow];
  flag := true;
  s := if flag then [] else [];
  if s <> [] then halt(1);
  s := [shLow];
  flag := false;
  s := if flag then [] else [];
  if s <> [] then halt(2);
end.
