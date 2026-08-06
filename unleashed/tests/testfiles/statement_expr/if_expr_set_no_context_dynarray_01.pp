program if_expr_set_no_context_dynarray_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);

var
  flag: boolean;
begin
  // without a set-typed context an inferred var keeps the dynamic-array
  // meaning of the constructors
  flag := true;
  var q := if flag then [shHigh] else [];
  if length(q) <> 1 then halt(1);
  if q[0] <> shHigh then halt(2);
  flag := false;
  var r := if flag then [shHigh] else [];
  if length(r) <> 0 then halt(3);
end.
