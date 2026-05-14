program match_all_fallthrough_01;

{$mode unleashed}

var
  hits: Integer;

begin
  hits := 0;

  match all 5 of
    5: Inc(hits);
    5: Inc(hits);
    _: Inc(hits);
  end;
  // all three branches match, so hits = 3
  if hits <> 3 then halt(1);

  hits := 0;
  match all 7 of
    5: Inc(hits);
    7: Inc(hits);
    _: Inc(hits);
  end;
  // only branches `7` and `_` match
  if hits <> 2 then halt(2);
end.
