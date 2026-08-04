program labels_long_range_01;

{$mode unleashed}

label
  state[0..9];

var
  hits: Integer = 0;

begin
  goto state[7];

  state[0]: Inc(hits, 1); goto done;
  state[1]: Inc(hits, 2); goto done;
  state[2]: Inc(hits, 3); goto done;
  state[3]: Inc(hits, 4); goto done;
  state[4]: Inc(hits, 5); goto done;
  state[5]: Inc(hits, 6); goto done;
  state[6]: Inc(hits, 7); goto done;
  state[7]: Inc(hits, 8); goto done;
  state[8]: Inc(hits, 9); goto done;
  state[9]: Inc(hits, 10);

done:
  if hits <> 8 then halt(1);
end.
