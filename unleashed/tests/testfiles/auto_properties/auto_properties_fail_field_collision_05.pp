{ %FAIL }
program auto_properties_fail_field_collision_05;

{$mode unleashed}

// FX already exists, so the synthesized backing field collides
type
  TFoo = class
    FX: Integer;
    property X: Integer;
  end;

begin
end.
