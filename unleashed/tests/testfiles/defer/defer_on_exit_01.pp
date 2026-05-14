program defer_on_exit_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork(early: Boolean);
begin
  defer trace := trace + 'cleanup;';
  trace := trace + 'start;';
  if early then Exit;
  trace := trace + 'end;';
end;

begin
  DoWork(true);
  if trace <> 'start;cleanup;' then halt(1);

  trace := '';
  DoWork(false);
  if trace <> 'start;end;cleanup;' then halt(2);
end.
