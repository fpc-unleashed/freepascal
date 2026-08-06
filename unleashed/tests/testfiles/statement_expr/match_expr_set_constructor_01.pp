program match_expr_set_constructor_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

var
  s: TShades;
  k: integer;
begin
  k := 1;
  s := match k of 1: [shHigh]; _: []; end;
  if s <> [shHigh] then halt(1);
  k := 5;
  s := match k of 1: [shHigh]; _: []; end;
  if s <> [] then halt(2);
end.
