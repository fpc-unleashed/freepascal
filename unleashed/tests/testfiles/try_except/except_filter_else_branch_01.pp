program except_filter_else_branch_01;

{$mode unleashed}

uses SysUtils;

procedure RaiseSome(kind: Integer);
begin
  case kind of
    1: raise EConvertError.Create('convert');
    2: raise EAbort.Create('abort');
  else
    raise Exception.Create('generic');
  end;
end;

function Catch(kind: Integer): String;
begin
  try
    RaiseSome(kind);
    Result := 'unreached';
  except
    on E: EConvertError do Result := 'convert';
    on E: EAbort do        Result := 'abort';
  else
    Result := 'else';
  end;
end;

begin
  if Catch(1) <> 'convert' then halt(1);
  if Catch(2) <> 'abort'   then halt(2);
  if Catch(9) <> 'else'    then halt(3);
end.
