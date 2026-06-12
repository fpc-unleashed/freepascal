program parallelfor_nested_09;
{$mode unleashed}
uses SysUtils;
// a parallel loop nested in another runs its body on the outer worker; the
// total still covers every (i,j) pair once
var s: Integer;
begin
  s := 0;
  for parallel var i := 1 to 4 do
    for parallel var j := 1 to 250 do InterlockedIncrement(s);
  if s <> 1000 then halt(1);
end.
