program match_all_leave_01;

{$mode unleashed}

var
  hits: Integer;

begin
  hits := 0;
  match all 5 of
    5: begin Inc(hits); leave; end;
    5: Inc(hits);
    _: Inc(hits);
  end;
  // first branch matches and leaves, others skipped
  if hits <> 1 then halt(1);
end.
