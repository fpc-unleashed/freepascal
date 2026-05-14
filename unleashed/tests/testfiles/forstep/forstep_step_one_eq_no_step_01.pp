program forstep_step_one_eq_no_step_01;

{$mode unleashed}

var
  visited: array of Integer = nil;

begin
  for var i := 1 to 5 step 1 do
    visited := visited + [i];
  // constant step 1 folds back to a regular for-loop, so body sees 1..5
  if Length(visited) <> 5 then halt(1);
  if visited[0] <> 1 then halt(2);
  if visited[4] <> 5 then halt(3);
end.
