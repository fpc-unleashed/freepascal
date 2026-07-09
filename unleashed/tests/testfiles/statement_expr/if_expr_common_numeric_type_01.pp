program if_expr_common_numeric_type_01;

{$mode unleashed}

// branch types must widen to a common numeric type instead of
// truncating the second branch to the first branch's type
var
  big: SizeInt = 311;
  cond: boolean = false;
begin
  var a := if cond then 0 else big;
  if a <> 311 then halt(1);

  var b := if cond then 3.5 else big;
  if b <> 311.0 then halt(2);

  var c := if not cond then -1 else 100000;
  if c <> -1 then halt(3);

  var d := if cond then big else 0;
  if d <> 0 then halt(4);

  var e := if not cond then big else 2.5;
  if e <> 311.0 then halt(5);
end.
