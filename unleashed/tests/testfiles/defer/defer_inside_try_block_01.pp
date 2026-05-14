program defer_inside_try_block_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
begin
  try
    defer trace := trace + 'd-try;';
    trace := trace + 'try-body;';
    raise Exception.Create('boom');
  except
    trace := trace + 'caught;';
  end;
  trace := trace + 'after;';
end;

begin
  DoWork;
  // defer scope is the try-body block; fires on exception path
  if trace <> 'try-body;d-try;caught;after;' then halt(1);
end.
