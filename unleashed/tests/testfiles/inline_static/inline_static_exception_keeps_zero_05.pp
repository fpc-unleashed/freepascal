program inline_static_exception_keeps_zero_05;
{$mode unleashed}

uses SysUtils;

var
  attempt: Integer = 0;

function MaybeFail: Integer;
begin
  Inc(attempt);
  if attempt = 1 then
    raise Exception.Create('boom');
  Result := 777;
end;

procedure Use;
begin
  static x := MaybeFail;
  // when the first call raised, x must keep its zero bytes
  if x <> 0 then halt(1);
end;

begin
  try
    Use;
    halt(2);  // first call should have raised
  except
    on E: Exception do ;
  end;
  // subsequent calls must skip the init block (guard set before eval)
  Use;
  Use;
  // MaybeFail must have run exactly once
  if attempt <> 1 then halt(20 + attempt);
end.
