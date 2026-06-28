{ %FAIL }
program auto_properties_fail_indexed_04;

{$mode unleashed}

// an indexed property cannot be backed by a single field
type
  TFoo = class
    property Items[i: Integer]: Integer;
  end;

begin
end.
