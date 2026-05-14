program forstep_step_overshoots_upper_bound_01;

{$mode unleashed}

var
  visited: array of Integer = nil;

begin
  // step is bigger than the range; only the lower bound runs
  for var i := 5 to 7 step 100 do
    visited := visited + [i];
  if Length(visited) <> 1 then halt(1);
  if visited[0]      <> 5 then halt(2);
end.
