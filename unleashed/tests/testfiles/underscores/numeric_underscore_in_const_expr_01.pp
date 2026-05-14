program numeric_underscore_in_const_expr_01;

{$mode unleashed}

const
  KB = 1_024;
  MB = 1_024 * 1_024;
  COLOR_MASK = $FF_FF_FF_00;

begin
  if KB <> 1024 then halt(1);
  if MB <> 1048576 then halt(2);
  if COLOR_MASK <> $FFFFFF00 then halt(3);
end.
