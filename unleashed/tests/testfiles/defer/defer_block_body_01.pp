program defer_block_body_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork;
begin
  defer
  begin
    trace := trace + '1;';
    trace := trace + '2;';
  end;
  trace := trace + 'mid;';
end;

begin
  DoWork;
  if trace <> 'mid;1;2;' then halt(1);
end.
