program not_in_set_01;

{$mode unleashed}

type
  TFruit = (apple, banana, cherry, date);

var
  f: TFruit;
  c: Char;

begin
  f := banana;
  if f not in [apple, cherry] then else halt(1);
  if f not in [banana, date]  then halt(2);

  c := 'x';
  if c not in ['a', 'b', 'c'] then else halt(3);
  if c not in ['x', 'y', 'z'] then halt(4);
end.
