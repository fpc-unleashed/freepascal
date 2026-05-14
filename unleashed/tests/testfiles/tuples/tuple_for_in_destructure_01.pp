program tuple_for_in_destructure_01;

{$mode unleashed}

begin
  var pairs: array of (Integer, String);
  pairs := [(1, 'a'), (2, 'b'), (3, 'c')];
  var sum := 0;
  var concat := '';
  for var (n, s) in pairs do
  begin
    sum := sum + n;
    concat := concat + s;
  end;
  if sum    <> 6     then halt(1);
  if concat <> 'abc' then halt(2);
end.
