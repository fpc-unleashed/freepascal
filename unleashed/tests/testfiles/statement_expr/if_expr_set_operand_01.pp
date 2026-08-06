program if_expr_set_operand_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

var
  s: TShades;
  flag: boolean;
begin
  // statement expression as an operand of set operators
  flag := true;
  s := [shLow];
  s := s + (if flag then [shHigh] else []);
  if s <> [shLow, shHigh] then halt(1);
  s := s - (if flag then [shLow] else []);
  if s <> [shHigh] then halt(2);
  s := s * (if flag then [shHigh, shMid] else []);
  if s <> [shHigh] then halt(3);
  flag := false;
  s := s + (if flag then [shLow] else []);
  if s <> [shHigh] then halt(4);
  s := s * (if flag then [shHigh] else []);
  if s <> [] then halt(5);
end.
