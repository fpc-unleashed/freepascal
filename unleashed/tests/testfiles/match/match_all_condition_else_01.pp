program match_all_condition_else_01;
// condition-based `match all`: else is a no-match fallback too

{$mode unleashed}

var
  n, hits, fallback: Integer;

begin
  // one condition true: else must not run
  n := 7;
  hits := 0;
  fallback := 0;
  match all
    n > 0: Inc(hits);
    n < 0: Inc(hits);
    else Inc(fallback);
  end;
  if hits <> 1 then halt(1);
  if fallback <> 0 then halt(2);

  // no condition true: else runs once
  n := 0;
  hits := 0;
  fallback := 0;
  match all
    n > 0: Inc(hits);
    n < 0: Inc(hits);
    else Inc(fallback);
  end;
  if hits <> 0 then halt(3);
  if fallback <> 1 then halt(4);
end.
