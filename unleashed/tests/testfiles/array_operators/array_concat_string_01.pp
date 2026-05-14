program array_concat_string_01;

{$mode unleashed}

begin
  var a: array of String := ['hello', 'world'];
  var b: array of String := ['foo', 'bar', 'baz'];
  var c := a + b;
  if Length(c) <> 5 then halt(1);
  if c[0] <> 'hello' then halt(2);
  if c[4] <> 'baz'   then halt(3);
end.
