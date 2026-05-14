program nested_try_with_match_01;

{$mode unleashed}

uses SysUtils;

procedure DoWork(level: Integer);
begin
  try
    try
      match level of
        1: raise Exception.Create('inner-1');
        2: raise EConvertError.Create('inner-2');
      end;
    except
      on E: EConvertError do
        raise Exception.Create('rewrapped: ' + E.Message);
    end;
  except
    on E: Exception do
    begin
      if (level = 2) and (Pos('rewrapped', E.Message) = 0) then halt(1);
      if (level = 1) and (E.Message <> 'inner-1') then halt(2);
    end;
  end;
end;

begin
  DoWork(1);
  DoWork(2);
end.
