program record_helper_extends_int_01;

{$mode unleashed}

type
  TIntHelper = record helper for Integer
    function Doubled: Integer;
  end;

function TIntHelper.Doubled: Integer;
begin
  Result := Self * 2;
end;

var
  n: Integer = 21;

begin
  if n.Doubled <> 42 then halt(1);
end.
