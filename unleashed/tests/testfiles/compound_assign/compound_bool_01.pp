program compound_bool_01;

{$mode unleashed}

begin
  var ok := true;
  ok and= (1 > 0);
  if not ok then halt(1);

  ok and= (1 > 9);
  if ok then halt(2);

  ok or= (1 > 0);
  if not ok then halt(3);
end.
