{ %FAIL }
program auto_properties_fail_write_readonly_07;

{$mode unleashed}

// a readonly auto-property has no write access, so external assignment fails
type
  TFoo = class
    property X: Integer; readonly;
  end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  f.X := 5;
  f.Free;
end.
