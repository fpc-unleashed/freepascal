program lock_nested_reentrant_01;
{$mode unleashed}

var
  counter: Integer;

procedure Inner;
begin
  lock(counter) do Inc(counter);
end;

procedure Outer;
begin
  lock(counter) do begin
    Inc(counter);
    // re-enters the SAME hidden CS - TRTLCriticalSection is
    // recursive on every supported target so this does not deadlock
    Inner;
    Inc(counter);
  end;
end;

begin
  counter := 0;
  Outer;
  if counter <> 3 then halt(1);
end.
