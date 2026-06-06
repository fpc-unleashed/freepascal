program inline_static_runtime_init_04;
{$mode unleashed}

var
  seed_calls: Integer = 0;

function ComputeSeed: Integer;
begin
  Inc(seed_calls);
  Result := 999;
end;

procedure Use;
begin
  static s := ComputeSeed;
  if s <> 999 then halt(1);
end;

begin
  Use;
  Use;
  Use;
  // ComputeSeed must have run exactly once
  if seed_calls <> 1 then halt(10 + seed_calls);
end.
