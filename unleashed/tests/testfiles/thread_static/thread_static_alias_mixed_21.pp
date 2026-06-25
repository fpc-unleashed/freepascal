program thread_static_alias_mixed_21;
{$mode unleashed}

// a `tstatic` section together with inline `threadstatic` and inline `tstatic`
// declarations in one routine; each has independent per-thread storage, checks
// init-once and cross-call persistence

function Work(step: Integer): LongInt;
tstatic
  sec: LongInt = 1000;
begin
  threadstatic inlc := 30;
  tstatic inld: LongInt;
  Inc(sec, step);
  Inc(inlc, step);
  Inc(inld, step);
  Result := sec + inlc*100 + inld*1000;
end;

begin
  // call 1: sec=1001, inlc=31, inld=1 -> 1001 + 3100 + 1000 = 5101
  if Work(1) <> 5101 then halt(1);
  // call 2 (same thread): sec=1002, inlc=32, inld=2 -> 1002 + 3200 + 2000 = 6202
  if Work(1) <> 6202 then halt(2);
end.
