program strinterp_basic_arithmetic_01;

{$mode unleashed}

var
  s: string;
  a, b: integer;
begin
  s := $'Sum: {2 + 3}';
  if s <> 'Sum: 5' then halt(1);

  a := 10;
  b := 3;
  s := $'{a * b}';
  if s <> '30' then halt(2);

  s := $'{a div b} r{a mod b}';
  if s <> '3 r1' then halt(3);
end.
