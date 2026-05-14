program tuple_compare_eq_01;

{$mode unleashed}

begin
  if (1, 2)  =  (1, 2) then else halt(1);
  if (1, 2) <>  (1, 2) then halt(2);
  if (1, 2)  =  (1, 3) then halt(3);
  if (1, 2) <>  (1, 3) then else halt(4);
end.
