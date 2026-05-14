program array_concat_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2, 3];
  var b: array of Integer := [4, 5];
  var c := a + b;
  if Length(c) <> 5 then halt(1);
  if c[0] <> 1 then halt(2);
  if c[2] <> 3 then halt(3);
  if c[3] <> 4 then halt(4);
  if c[4] <> 5 then halt(5);
end.
