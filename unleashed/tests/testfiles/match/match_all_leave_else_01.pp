program match_all_leave_else_01;
// `leave` from a matched branch skips the rest of the block,
// including the else fallback

{$mode unleashed}

var
  hits, fallback: Integer;

begin
  hits := 0;
  fallback := 0;
  match all 5 of
    5: begin Inc(hits); leave; end;
    5: Inc(hits);
    else Inc(fallback);
  end;
  if hits <> 1 then halt(1);
  if fallback <> 0 then halt(2);
end.
