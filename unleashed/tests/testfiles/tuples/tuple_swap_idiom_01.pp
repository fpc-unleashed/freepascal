program tuple_swap_idiom_01;

{$mode unleashed}

var
  x, y: Integer;

begin
  x := 100;
  y := 200;
  (x, y) := (y, x);
  if x <> 200 then halt(1);
  if y <> 100 then halt(2);
end.
