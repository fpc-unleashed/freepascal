{ %FAIL }
program thread_static_scope_local_06;
{$mode unleashed}

// threadstatic follows normal Pascal scoping - the sym lives in the
// declaring routine's localst, invisible to siblings. `cnt_local` is
// declared inside `Inner` and must not be reachable from `Outer`.

procedure Inner;
begin
  threadstatic cnt_local := 0;
end;

procedure Outer;
begin
  WriteLn(cnt_local);   // should fail - not in scope
end;

begin
  Outer;
end.
