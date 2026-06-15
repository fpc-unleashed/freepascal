program auto_properties_writeonly_03;

{$mode unleashed}

type
  TVault = class
    property Secret: String; writeonly;   // auto: write FSecret only
    function Peek: String;
  end;

function TVault.Peek: String;
begin
  Result := FSecret;     // backing field is readable from inside the class
end;

var
  v: TVault;
begin
  v := TVault.Create;
  v.Secret := 'shh';
  if v.Peek <> 'shh' then halt(1);
  v.Free;
end.
