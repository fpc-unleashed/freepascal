program record_helper_extends_class_01;

{$mode unleashed}

type
  TFoo = class
    value: Integer;
  end;

  TFooHelper = record helper for TFoo
    function Doubled: Integer;
  end;

function TFooHelper.Doubled: Integer;
begin
  Result := Self.value * 2;
end;

var
  f: TFoo;

begin
  f := autofree TFoo.Create;
  f.value := 21;
  if f.Doubled <> 42 then halt(1);
end.
