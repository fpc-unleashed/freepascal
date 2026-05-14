program defer_on_exception_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
begin
  defer trace := trace + 'cleanup;';
  trace := trace + 'start;';
  raise Exception.Create('boom');
end;

begin
  try
    DoWork;
  except
    trace := trace + 'caught;';
  end;
  // defer fires on exception path before unwinding
  if trace <> 'start;cleanup;caught;' then halt(1);
end.
