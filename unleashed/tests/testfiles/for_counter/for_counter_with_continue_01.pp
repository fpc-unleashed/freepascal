program for_counter_with_continue_01;

{$mode unleashed}

var
  i: Integer;
  visited: array of Integer = nil;

begin
  for i := 1 to 5 do
  begin
    if i = 3 then continue;
    visited := visited + [i];
  end;
  // counter still ends at 5 (natural exit) per unleashed semantics
  if i <> 5 then halt(1);
  if Length(visited) <> 4 then halt(2);
end.
