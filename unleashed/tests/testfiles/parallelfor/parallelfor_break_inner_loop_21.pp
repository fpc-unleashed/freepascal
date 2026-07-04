program parallelfor_break_inner_loop_21;
{$mode unleashed}
uses SysUtils;
// a break inside a nested classic loop binds to that loop; the parallel loop
// keeps running all its iterations
var n: Integer;
begin
  n := 0;
  for parallel var i := 1 to 50 do
  begin
    for var j := 1 to 100 do
      if j = 3 then break;
    InterlockedIncrement(n);
  end;
  if n <> 50 then halt(1);
end.
