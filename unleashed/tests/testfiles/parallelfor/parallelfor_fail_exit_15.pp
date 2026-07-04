{ %FAIL }
program parallelfor_fail_exit_15;
{$mode unleashed}
// exit cannot leave a parallel body
procedure p;
begin
  for parallel var i := 1 to 5 do
    if i = 3 then exit;
end;
begin
  p;
end.
