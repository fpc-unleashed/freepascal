program tuple_swap_three_01;

{$mode unleashed}

var
  a, b, c: Integer;

begin
  a := 1; b := 2; c := 3;
  // rotate left
  (a, b, c) := (b, c, a);
  if a <> 2 then halt(1);
  if b <> 3 then halt(2);
  if c <> 1 then halt(3);
end.
