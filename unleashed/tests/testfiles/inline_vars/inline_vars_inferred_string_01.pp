program inline_vars_inferred_string_01;

{$mode unleashed}

begin
  var s := 'hello';
  if s <> 'hello' then halt(1);
  if Length(s) <> 5 then halt(2);
  s := s + ' world';
  if s <> 'hello world' then halt(3);
end.
