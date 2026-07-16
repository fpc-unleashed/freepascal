program asyncawait_auto_property_write_27;
{$mode unleashed}
{$autopropprefix _}

// an auto-property backing field is strict private; both the property and
// its backing field must be writable from an async block in the own class
uses
  SysUtils;

type
  TFoo = class
  public
    property prop: Integer;
    procedure Go;
  end;

procedure TFoo.Go;
begin
  var f := async begin _prop := 4; end;
  await f;
  var g := async begin Self.prop := prop + 30; end;
  await g;
end;

var
  a: TFoo;
begin
  a := TFoo.Create;
  a.Go;
  if a.prop <> 34 then halt(1);
  a.Free;
end.
