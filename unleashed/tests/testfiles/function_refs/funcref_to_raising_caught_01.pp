program funcref_to_raising_caught_01;

{$mode unleashed}

uses SysUtils;

type
  TAction = reference to procedure;

procedure Boom;
begin
  raise Exception.Create('boom');
end;

begin
  var f: TAction := @Boom;
  var caught := false;
  try
    f;
  except
    on E: Exception do
      if E.Message = 'boom' then caught := true;
  end;
  if not caught then halt(1);
end.
