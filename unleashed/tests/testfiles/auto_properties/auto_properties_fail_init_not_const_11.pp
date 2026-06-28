{ %FAIL }
program auto_properties_fail_init_not_const_11;

{$mode unleashed}

// the initializer value must be a compile-time constant
function F: Integer;
begin
  Result := 1;
end;

type
  TFoo = class
    property X: Integer = F;
  end;

begin
end.
