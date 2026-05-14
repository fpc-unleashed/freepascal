program inline_vars_inferred_int_01;

{$mode unleashed}

begin
  var x := 42;
  if x <> 42 then halt(1);
  if SizeOf(x) <> SizeOf(LongInt) then halt(2);
end.
