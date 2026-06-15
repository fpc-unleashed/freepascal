{ %FAIL }
program auto_properties_fail_backing_strict_private_09;

{$mode unleashed}

// the synthesized backing field is strict private, so it is not visible to
// descendants - only the declaring class reaches it by name
type
  TBase = class
    property Caption: String;
  end;

  TDerived = class(TBase)
    function Peek: String;
  end;

function TDerived.Peek: String;
begin
  Result := FCaption;
end;

begin
end.
