program array_concat_with_self_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2, 3];
  a := a + a;
  if Length(a) <> 6 then halt(1);
  if a[0] <> 1 then halt(2);
  if a[3] <> 1 then halt(3);
  if a[5] <> 3 then halt(4);
end.
