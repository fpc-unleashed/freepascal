{ %FAIL }
program match_fail_control_body_branch_01;
// inline var cannot be the only statement of a match branch

{$mode unleashed}

var
  x: integer;

begin
  x := 1;
  match x of
    1: var b := 2;
  end;
end.
