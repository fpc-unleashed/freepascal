program array_equality_string_01;

{$mode unleashed}

begin
  var a: array of String := ['hello', 'world'];
  var b: array of String := ['hello', 'world'];
  var c: array of String := ['hello', 'WORLD'];

  if a <> b then halt(1);
  if a  = c then halt(2);
end.
