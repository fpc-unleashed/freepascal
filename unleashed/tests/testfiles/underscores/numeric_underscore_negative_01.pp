program numeric_underscore_negative_01;

{$mode unleashed}

begin
  var minus_million := -1_000_000;
  if minus_million <> -1000000 then halt(1);
end.
