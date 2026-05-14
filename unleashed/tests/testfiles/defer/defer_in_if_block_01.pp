program defer_in_if_block_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork(branch: Boolean);
begin
  if branch then
  begin
    defer trace := trace + 'taken;';
    trace := trace + 'inside-true;';
  end
  else
  begin
    defer trace := trace + 'else;';
    trace := trace + 'inside-false;';
  end;
  trace := trace + 'after;';
end;

begin
  DoWork(true);
  if trace <> 'inside-true;taken;after;' then halt(1);

  trace := '';
  DoWork(false);
  if trace <> 'inside-false;else;after;' then halt(2);
end.
