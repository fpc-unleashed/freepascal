program auto_properties_init_constructor_wins_14;

{$mode unleashed}

// the initializer seeds the field before the constructor body runs, so the
// constructor can override it
type
  TConfig = class
    property Port: Integer = 8080;
    constructor Create(aPort: Integer);
  end;

constructor TConfig.Create(aPort: Integer);
begin
  FPort := aPort;
end;

var
  c: TConfig;
begin
  c := TConfig.Create(443);
  if c.Port <> 443 then halt(1);
  c.Free;
end.
