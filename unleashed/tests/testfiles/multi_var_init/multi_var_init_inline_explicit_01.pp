program multi_var_init_inline_explicit_01;

{$mode unleashed}

begin
  var p, q: Integer := 99;
  if p <> 99 then halt(1);
  if q <> 99 then halt(2);
  p := 0;
  if q <> 99 then halt(3);
end.
