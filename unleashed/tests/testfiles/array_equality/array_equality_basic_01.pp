program array_equality_basic_01;

{$mode unleashed}

begin
  var a: array of Integer := [1, 2, 3];
  var b: array of Integer := [1, 2, 3];
  var c: array of Integer := [1, 2, 4];

  if a <> b then halt(1);
  if a  = c then halt(2);
  if not (a <> c) then halt(3);
end.
