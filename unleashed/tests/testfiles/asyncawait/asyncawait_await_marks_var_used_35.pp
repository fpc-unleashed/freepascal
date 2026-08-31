{ %OPT=-Sen }
{ awaiting a future marks the variable as used; -Sen turns the spurious
  "assigned but never used" note into a compile error }
program asyncawait_await_marks_var_used_35;
{$mode unleashed}
function fetch: integer;
begin
  result := 7;
end;
procedure run;
begin
  var f := async fetch;
  if await f <> 7 then halt(1);
end;
begin
  run;
end.
