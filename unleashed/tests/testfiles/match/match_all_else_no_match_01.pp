program match_all_else_no_match_01;

{$mode unleashed}

var
  hits, fallback: Integer;

begin
  // a branch matched: else must not run
  hits := 0;
  fallback := 0;
  match all 5 of
    5: Inc(hits);
    5: Inc(hits);
    3: Inc(hits);
    else Inc(fallback);
  end;
  if hits <> 2 then halt(1);
  if fallback <> 0 then halt(2);

  // nothing matched: else runs once
  hits := 0;
  fallback := 0;
  match all 7 of
    5: Inc(hits);
    3: Inc(hits);
    else Inc(fallback);
  end;
  if hits <> 0 then halt(3);
  if fallback <> 1 then halt(4);
end.
