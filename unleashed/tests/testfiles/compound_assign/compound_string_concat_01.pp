program compound_string_concat_01;

{$mode unleashed}

begin
  var s := 'foo';
  s += 'bar';
  if s <> 'foobar' then halt(1);
  s += '!';
  if s <> 'foobar!' then halt(2);
end.
