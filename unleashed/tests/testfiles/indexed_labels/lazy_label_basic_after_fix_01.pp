program lazy_label_basic_after_fix_01;
{$mode unleashed}

// positive coverage: lazy label declaration still works for a label that
// is REFERENCED via `goto` before the declaration appears in the source
// (statement parser opts into lazy-label creation, so the forward goto
// target resolves to the implicitly created sym)
procedure main;
var n: Integer;
begin
  n := 0;
  goto cleanup;
  Inc(n, 100); // unreachable
  cleanup:
  Inc(n);
  if n <> 1 then Halt(1);
end;

begin
  main;
end.
