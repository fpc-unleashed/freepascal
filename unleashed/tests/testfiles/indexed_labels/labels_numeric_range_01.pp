program labels_numeric_range_01;

{$mode unleashed}

label
  state[0..3];

var
  hits: Integer = 0;

begin
  goto state[2];

  state[0]: Inc(hits, 1); goto done;
  state[1]: Inc(hits, 10); goto done;
  state[2]: Inc(hits, 100); goto done;
  state[3]: Inc(hits, 1000);

done:
  if hits <> 100 then halt(1);
end.
