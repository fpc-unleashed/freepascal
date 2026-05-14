program forstep_with_const_step_01;

{$mode unleashed}

const
  STEP = 7;

var
  visited: array of Integer = nil;

begin
  for var i := 0 to 30 step STEP do
    visited := visited + [i];
  // body runs at 0, 7, 14, 21, 28
  if Length(visited) <> 5 then halt(1);
  if visited[0]      <> 0  then halt(2);
  if visited[4]      <> 28 then halt(3);
end.
