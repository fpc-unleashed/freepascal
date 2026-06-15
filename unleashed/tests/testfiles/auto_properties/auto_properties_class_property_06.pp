program auto_properties_class_property_06;

{$mode unleashed}

// a class property gets a class var (static) backing field, shared by all
// instances and reachable without one
type
  TRegistry = class
    class property Count: Integer;
  end;

begin
  TRegistry.Count := 0;
  TRegistry.Count := TRegistry.Count + 3;
  if TRegistry.Count <> 3 then halt(1);
  TRegistry.Count := TRegistry.Count + 1;
  if TRegistry.Count <> 4 then halt(2);
end.
