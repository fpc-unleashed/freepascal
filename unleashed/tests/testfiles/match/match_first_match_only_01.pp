program match_first_match_only_01;

{$mode unleashed}

var
  hits: Integer = 0;

begin
  // first matching branch wins, others skipped (without `match all`)
  match 5 of
    5: Inc(hits, 1);
    5: Inc(hits, 100);   // also matches but gets skipped
    _: Inc(hits, 1000);
  end;
  if hits <> 1 then halt(1);
end.
