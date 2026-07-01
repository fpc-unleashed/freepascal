{ %FAIL }
program lock_fail_local_var_01;
{$mode unleashed}

// `lock(localVar)` cannot auto-generate a hidden CS because the
// variable's storage is per-call, not global - compiler must reject
procedure Foo;
var
  local: Integer;
begin
  local := 0;
  lock(local) do Inc(local);
end;

begin
  Foo;
end.
