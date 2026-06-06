program inline_static_inferred_01;
{$mode unleashed}

procedure Tick;
begin
  static cnt := 0;
  Inc(cnt);
  if cnt > 4 then halt(1);
end;

begin
  Tick;
  Tick;
  Tick;
  Tick;
end.
