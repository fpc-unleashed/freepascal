program inline_vars_inferred_bool_01;

{$mode unleashed}

begin
  var b := true;
  if not b then halt(1);
  b := false;
  if b then halt(2);
  var c := (1 < 2);
  if not c then halt(3);
end.
