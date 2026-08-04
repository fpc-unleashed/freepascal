program labels_lazy_indexed_01;

{$mode unleashed}

var
  hits: Integer = 0;

begin
  goto step[1];
  step[0]: Inc(hits, 1); goto done;
  step[1]: Inc(hits, 10); goto done;
done:
  if hits <> 10 then halt(1);
end.
