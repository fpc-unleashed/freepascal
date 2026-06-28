{ %FAIL }
program auto_properties_fail_init_explicit_read_10;

{$mode unleashed}

// an initializer only applies to a synthesized backing field, not to a
// property with an explicit accessor
type
  TFoo = class
    function GetX: Integer;
    property X: Integer = 5 read GetX;
  end;

function TFoo.GetX: Integer;
begin
  Result := 0;
end;

begin
end.
