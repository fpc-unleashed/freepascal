program array_equality_after_concat_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2];
  var b: array of Integer := [3, 4];
  var c: array of Integer := [1, 2, 3, 4];

  if a + b <> c then halt(1);
  if (a + b)  = a then halt(2);
end.
