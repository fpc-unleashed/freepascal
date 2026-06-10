program strinterp_types_integer_01;

{$mode unleashed}

var
  i: integer;
  b: byte;
  q: qword;
  s: string;
begin
  i := -42;
  s := $'{i}';
  if s <> '-42' then halt(1);

  b := 255;
  s := $'{b}';
  if s <> '255' then halt(2);

  q := high(qword);
  s := $'{q}';
  if s <> '18446744073709551615' then halt(3);
end.
