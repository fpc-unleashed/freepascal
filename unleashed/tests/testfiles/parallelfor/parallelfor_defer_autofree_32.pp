program parallelfor_defer_autofree_32;
{$mode unleashed}
uses SysUtils, Classes;
// defer fires per iteration on the worker; autofree cleans up per iteration
var n, d, total: Integer;
begin
  n := 0; d := 0;
  for parallel var i := 1 to 1000 do
  begin
    defer InterlockedIncrement(d);
    InterlockedIncrement(n);
  end;
  if (n <> 1000) or (d <> 1000) then halt(1);
  total := 0;
  for parallel var i := 1 to 200 do
    with var sl := autofree TStringList.Create do
    begin
      sl.Add('x');
      InterlockedExchangeAdd(total, sl.Count);
    end;
  if total <> 200 then halt(2);
end.
