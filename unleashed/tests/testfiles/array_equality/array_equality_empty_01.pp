program array_equality_empty_01;

{$mode unleashed}

begin
  var a: array of Integer := nil;
  var b: array of Integer := nil;
  var c: array of Integer := [];

  if a <> b then halt(1);
  if a <> c then halt(2);   // both empty, should be equal
end.
