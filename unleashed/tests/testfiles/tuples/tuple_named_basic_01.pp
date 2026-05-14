program tuple_named_basic_01;

{$mode unleashed}

var
  p: (x, y: Integer);

begin
  p.x := 10;
  p.y := 20;
  if p.x <> 10 then halt(1);
  if p.y <> 20 then halt(2);
end.
