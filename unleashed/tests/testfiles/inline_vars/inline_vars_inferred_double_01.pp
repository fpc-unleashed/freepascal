program inline_vars_inferred_double_01;

{$mode unleashed}

begin
  var pi := 3.14;
  if pi < 3.13 then halt(1);
  if pi > 3.15 then halt(2);
  if SizeOf(pi) <> SizeOf(Double) then halt(3);
end.
