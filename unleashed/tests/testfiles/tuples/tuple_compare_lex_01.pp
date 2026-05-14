program tuple_compare_lex_01;

{$mode unleashed}

begin
  if not ((1, 2) < (1, 5)) then halt(1);
  if not ((1, 5) > (1, 2)) then halt(2);
  if (1, 2) < (1, 2) then halt(3);
  if (2, 0) < (1, 99) then halt(4);
  if (1, 99) < (2, 0) then else halt(5);
end.
