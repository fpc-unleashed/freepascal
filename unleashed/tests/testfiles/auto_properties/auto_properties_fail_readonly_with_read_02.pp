{ %FAIL }
program auto_properties_fail_readonly_with_read_02;

{$mode unleashed}

// readonly only applies to an accessor-less property; with an explicit read
// the directive is rejected
type
  TFoo = class
    function GetX: Integer;
    property X: Integer read GetX; readonly;
  end;

function TFoo.GetX: Integer;
begin
  Result := 0;
end;

begin
end.
