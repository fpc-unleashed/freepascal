{ %FAIL }
program auto_properties_fail_read_writeonly_08;

{$mode unleashed}

// a writeonly auto-property has no read access, so reading it fails
type
  TFoo = class
    property X: Integer; writeonly;
  end;

var
  f: TFoo;
  v: Integer;
begin
  f := TFoo.Create;
  v := f.X;
  f.Free;
end.
