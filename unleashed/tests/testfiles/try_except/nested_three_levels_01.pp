program nested_three_levels_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
begin
  try
    try
      try
        raise Exception.Create('innermost');
      except
        on E: Exception do
        begin
          trace := trace + 'L3;';
          raise;
        end;
      end;
    except
      on E: Exception do
      begin
        trace := trace + 'L2;';
        raise EConvertError.Create('rewrap');
      end;
    end;
  except
    on E: EConvertError do
      trace := trace + 'L1-EConvert;';
    on E: Exception do
      trace := trace + 'L1-Generic;';
  end;
end;

begin
  DoWork;
  if trace <> 'L3;L2;L1-EConvert;' then halt(1);
end.
