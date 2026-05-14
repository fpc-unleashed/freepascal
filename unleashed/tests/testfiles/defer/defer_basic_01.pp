program defer_basic_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork;
begin
  trace := trace + '1';
  defer trace := trace + 'D';
  trace := trace + '2';
end;

begin
  DoWork;
  // defer fires at end of enclosing block, after '2' is appended
  if trace <> '12D' then halt(1);
end.
