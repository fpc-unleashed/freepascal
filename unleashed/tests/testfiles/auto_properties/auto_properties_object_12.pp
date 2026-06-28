program auto_properties_object_12;

{$mode unleashed}

// old-style objects support auto-properties too; the backing field is an
// ordinary object field
type
  TOldObj = object
    property Value: Integer;
    property Name: String; readonly;
    procedure Init(v: Integer; const s: String);
  end;

procedure TOldObj.Init(v: Integer; const s: String);
begin
  FValue := v;
  FName := s;
end;

var
  o: TOldObj;
begin
  o.Init(7, 'obj');
  o.Value := o.Value + 3;
  if o.Value <> 10 then halt(1);
  if o.Name <> 'obj' then halt(2);
end.
