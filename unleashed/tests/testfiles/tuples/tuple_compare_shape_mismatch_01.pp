{$mode unleashed}
{ test different-shape tuple comparison }
program tuple_compare_shape_mismatch_01;

var
  a: (Integer, Integer);
  b: (Integer, Integer, Integer);
begin
  a := (1, 2);
  b := (1, 2, 3);

  { different shapes: = returns false, <> returns true }
  if a = b then halt(1);
  if not (a <> b) then halt(2);

  { same values but different field count }
  b := (1, 2, 0);
  if a = b then halt(3);
  if not (a <> b) then halt(4);

  writeln('ok');
end.
