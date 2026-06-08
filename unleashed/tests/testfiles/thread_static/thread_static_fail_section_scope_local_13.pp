{ %FAIL }
program thread_static_fail_section_scope_local_13;
{$mode unleashed}

// section-form threadstatic follows normal Pascal scoping: the sym lives
// in the declaring routine's localst, invisible to siblings. `cnt` is
// declared in `Inner`'s section and must not be reachable from `Outer`.

procedure Inner;
threadstatic
  cnt: Integer = 0;
begin
  Inc(cnt);
end;

procedure Outer;
begin
  WriteLn(cnt);   // should fail - not in scope
end;

begin
  Outer;
end.
