program defer_lifo_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork;
begin
  defer trace := trace + 'A';
  defer trace := trace + 'B';
  defer trace := trace + 'C';
end;

begin
  DoWork;
  // last registered fires first
  if trace <> 'CBA' then halt(1);
end.
