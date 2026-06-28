program auto_properties_inheritance_08;

{$mode unleashed}

// an auto-property declared on a base class is fully usable through descendants
type
  TBase = class
    property Caption: String;
  end;

  TDerived = class(TBase)
    function Shout: String;
  end;

function TDerived.Shout: String;
begin
  Result := Caption + '!';   // descendant uses the inherited property
end;

var
  d: TDerived;
begin
  d := TDerived.Create;
  d.Caption := 'hi';
  if d.Caption <> 'hi' then halt(1);
  if d.Shout <> 'hi!' then halt(2);
  d.Free;
end.
