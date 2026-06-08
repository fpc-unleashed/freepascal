program thread_static_runtime_init_03;
{$mode unleashed}

// runtime initializer (function call) runs on first reach per thread;
// in single-thread main body it runs exactly once

var
  seed_calls: Integer = 0;

function ComputeSeed: Integer;
begin
  Inc(seed_calls);
  Result := 1000 + seed_calls;
end;

function Use: Integer;
begin
  threadstatic seed := ComputeSeed;
  Result := seed;
end;

begin
  if Use <> 1001 then halt(1);
  if Use <> 1001 then halt(2);
  if Use <> 1001 then halt(3);
  if seed_calls <> 1 then halt(10 + seed_calls);
end.
