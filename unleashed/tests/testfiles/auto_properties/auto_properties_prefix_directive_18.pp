program auto_properties_prefix_directive_18;

{$mode unleashed}
{$autopropprefix _}

// the backing field is named _value, not Fvalue; referencing it by name
// only compiles if the directive changed the prefix
type
  TBox = class
    property value: Integer;
    procedure SetIt;
  end;

procedure TBox.SetIt;
begin
  _value := 7;
end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.SetIt;
  if b.value <> 7 then halt(1);
  b.value := 9;
  if b.value <> 9 then halt(2);
  b.Free;
end.
