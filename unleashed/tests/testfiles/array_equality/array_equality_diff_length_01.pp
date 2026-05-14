program array_equality_diff_length_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2, 3];
  var b: array of Integer := [1, 2, 3, 4];
  if a = b then halt(1);
end.
