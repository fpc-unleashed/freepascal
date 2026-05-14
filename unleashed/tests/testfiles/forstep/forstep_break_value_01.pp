program forstep_break_value_01;

{$mode unleashed}

var
  visited: array of Integer = nil;
  i: Integer;

begin
  for i := 1 to 10 step 4 do
    visited := visited + [i];
  // body must have run exactly at 1, 5, 9 (and nowhere else)
  if Length(visited) <> 3 then halt(1);
  if visited[0]      <> 1 then halt(2);
  if visited[1]      <> 5 then halt(3);
  if visited[2]      <> 9 then halt(4);
end.
