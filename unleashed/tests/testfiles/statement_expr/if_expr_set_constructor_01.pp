program if_expr_set_constructor_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

var
  s: TShades;
  flag: boolean;
begin
  // bare constructors in both branches take the set type of the target
  flag := true;
  s := if flag then [shHigh] else [];
  if s <> [shHigh] then halt(1);
  flag := false;
  s := if flag then [shHigh] else [];
  if s <> [] then halt(2);
  s := if flag then [shLow] else [shMid, shHigh];
  if s <> [shMid, shHigh] then halt(3);
end.
