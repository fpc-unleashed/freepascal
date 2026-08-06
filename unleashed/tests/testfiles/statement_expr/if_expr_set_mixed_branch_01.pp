program if_expr_set_mixed_branch_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

var
  s, other: TShades;
  flag: boolean;
begin
  // one branch a typed set variable, the other a bare constructor
  other := [shMid];
  flag := true;
  s := if flag then other else [];
  if s <> [shMid] then halt(1);
  flag := false;
  s := if flag then other else [];
  if s <> [] then halt(2);
  s := if flag then other else other;
  if s <> [shMid] then halt(3);
end.
