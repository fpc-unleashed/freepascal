program array_concat_with_literal_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2, 3];
  a := a + [4, 5];
  if Length(a) <> 5 then halt(1);
  if a[4] <> 5 then halt(2);

  // append single element via singleton literal
  a := a + [99];
  if Length(a) <> 6 then halt(3);
  if a[5] <> 99 then halt(4);
end.
