program defer_with_raise_after_register_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
begin
  defer trace := trace + 'D1;';
  trace := trace + 'before-raise;';
  raise Exception.Create('boom');
  trace := trace + 'never;';
end;

begin
  try
    DoWork;
  except
    trace := trace + 'caught;';
  end;
  // defer must fire on the exception path between raise and unwinding
  if trace <> 'before-raise;D1;caught;' then halt(1);
end.
