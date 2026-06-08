program thread_static_basic_01;
{$mode unleashed}

// inline threadstatic: per-thread storage, init runs once per thread
// on first reach; in single-thread main body it just behaves like a
// program-wide static
function Next: Integer;
begin
  threadstatic n := 0;
  Inc(n);
  Result := n;
end;

begin
  if Next <> 1 then halt(1);
  if Next <> 2 then halt(2);
  if Next <> 3 then halt(3);
end.
