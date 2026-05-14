program tuple_compare_different_shape_01;

{$mode unleashed}

begin
  // different shapes: = returns false, <> returns true, no compile error
  if (1, 2)     = (1, 2, 3) then halt(1);
  if (1, 2)    <> (1, 2, 3) then else halt(2);
  if (1, 'a')   = (1, 2)    then halt(3);
end.
