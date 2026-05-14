program multi_var_init_int_01;

{$mode unleashed}

var
  a, b, c: Integer = 42;

begin
  if a <> 42 then halt(1);
  if b <> 42 then halt(2);
  if c <> 42 then halt(3);
  // independent copies: changing one does not affect others
  a := 0;
  if b <> 42 then halt(4);
  if c <> 42 then halt(5);
end.
