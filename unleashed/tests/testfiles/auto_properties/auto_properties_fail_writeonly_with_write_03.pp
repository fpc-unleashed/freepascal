{ %FAIL }
program auto_properties_fail_writeonly_with_write_03;

{$mode unleashed}

// writeonly only applies to an accessor-less property; with an explicit write
// the directive is rejected
type
  TFoo = class
    procedure SetX(v: Integer);
    property X: Integer write SetX; writeonly;
  end;

procedure TFoo.SetX(v: Integer);
begin
end;

begin
end.
