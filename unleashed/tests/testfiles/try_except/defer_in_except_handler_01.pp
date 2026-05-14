program defer_in_except_handler_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
begin
  try
    raise Exception.Create('boom');
  except
    on E: Exception do
    begin
      defer trace := trace + 'defer-handler;';
      trace := trace + 'inside-handler;';
    end;
  end;
  trace := trace + 'after;';
end;

begin
  DoWork;
  if trace <> 'inside-handler;defer-handler;after;' then halt(1);
end.
