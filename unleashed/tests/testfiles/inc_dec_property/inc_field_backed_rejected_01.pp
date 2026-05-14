{ %FAIL }
program inc_field_backed_rejected_01;

{$mode unleashed}

type
  TFoo = class
  public
    F: Integer;
    property N: Integer read F write F;   // field-backed, no method
  end;

begin
  var f := TFoo.Create;
  // inc on a property whose getter is a plain field is rejected
  Inc(f.N);
  f.Free;
end.
