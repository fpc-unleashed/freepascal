program tuple_three_field_compare_01;

{$mode unleashed}

begin
  if (1, 2, 3) <> (1, 2, 3) then halt(1);
  if (1, 2, 3)  = (1, 2, 4) then halt(2);
  if (1, 2, 3) <  (1, 2, 4) then else halt(3);
  if (1, 2, 4) >  (1, 2, 3) then else halt(4);
  if (1, 2, 3) <  (2, 0, 0) then else halt(5);   // first field differs
end.
