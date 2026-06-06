program static_section_persists_02;
{$mode unleashed}

function NextId: Integer;
static
  next: Integer = 100;
begin
  Result := next;
  Inc(next);
end;

begin
  if NextId <> 100 then halt(1);
  if NextId <> 101 then halt(2);
  if NextId <> 102 then halt(3);
  if NextId <> 103 then halt(4);
end.
