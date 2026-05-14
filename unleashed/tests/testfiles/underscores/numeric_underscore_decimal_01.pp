program numeric_underscore_decimal_01;

{$mode unleashed}

begin
  var million := 1_000_000;
  if million <> 1000000 then halt(1);

  var billion := 1_000_000_000;
  if billion <> 1000000000 then halt(2);
end.
