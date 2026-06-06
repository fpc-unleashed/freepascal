program inline_static_persists_03;
{$mode unleashed}

function NextId: Integer;
begin
  static next := 1000;
  Result := next;
  Inc(next);
end;

begin
  if NextId <> 1000 then halt(1);
  if NextId <> 1001 then halt(2);
  if NextId <> 1002 then halt(3);
end.
