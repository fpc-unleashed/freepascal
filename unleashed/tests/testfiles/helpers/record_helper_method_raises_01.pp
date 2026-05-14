program record_helper_method_raises_01;

{$mode unleashed}

uses SysUtils;

type
  TPair = record
    a, b: Integer;
  end;

  TPairHelper = record helper for TPair
    function SafeRatio: Double;
  end;

function TPairHelper.SafeRatio: Double;
begin
  if Self.b = 0 then
    raise EDivByZero.Create('zero denominator');
  Result := Self.a / Self.b;
end;

var
  p: TPair;

begin
  p.a := 10; p.b := 4;
  if p.SafeRatio <> 2.5 then halt(1);

  p.b := 0;
  var caught := false;
  try
    p.SafeRatio;
  except
    on E: EDivByZero do caught := true;
  end;
  if not caught then halt(2);
end.
