program reraise_with_modified_message_01;

{$mode unleashed}

uses SysUtils;

procedure Inner;
begin
  raise Exception.Create('orig');
end;

procedure Wrapper;
begin
  try
    Inner;
  except
    on E: Exception do
      raise Exception.Create('wrapped: ' + E.Message);
  end;
end;

begin
  var got: String := '';
  try
    Wrapper;
  except
    on E: Exception do
      got := E.Message;
  end;
  if got <> 'wrapped: orig' then halt(1);
end.
