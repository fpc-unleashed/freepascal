program anon_raising_caught_01;

{$mode unleashed}

uses SysUtils;

type
  TAction = reference to procedure;

begin
  var raiser: TAction := procedure
                         begin
                           raise Exception.Create('from-anon');
                         end;
  var caught_msg := '';
  try
    raiser;
  except
    on E: Exception do caught_msg := E.Message;
  end;
  if caught_msg <> 'from-anon' then halt(1);
end.
