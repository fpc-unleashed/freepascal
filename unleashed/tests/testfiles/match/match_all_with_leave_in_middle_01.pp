program match_all_with_leave_in_middle_01;

{$mode unleashed}

var
  trace: String = '';

begin
  match all 5 of
    5: trace := trace + 'A;';
    5: begin trace := trace + 'B;'; leave; end;
    5: trace := trace + 'C;';
    _: trace := trace + 'else;';
  end;
  // first matches and runs, second matches+leaves, third never reached
  if trace <> 'A;B;' then halt(1);
end.
