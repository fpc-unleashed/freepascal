program lazy_label_in_match_branch_body_01;
{$mode unleashed}

// lazy label declared as the only statement in a match branch body:
// branch body calls statement() recursively, so the opt-in flag is
// preserved and the implicit label sym still gets registered
procedure main;
var
  n: Integer;
  hits: Integer;
begin
  hits := 0;
  for n := 1 to 3 do
    match n of
      2: begin lbl: Inc(hits, 10); end;
      _: Inc(hits);
    end;
  if hits <> 12 then Halt(1);
end;

begin
  main;
end.
