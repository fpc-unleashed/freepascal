{ %FAIL }
program auto_properties_fail_init_indexed_12;

{$mode unleashed}

// an indexed property has no single backing field, so an initializer is invalid
type
  TFoo = class
    property Items[i: Integer]: Integer = 0;
  end;

begin
end.
