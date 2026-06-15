program auto_properties_init_basic_13;

{$mode unleashed}

// `= constexpr` seeds the backing field at construction; works without an
// explicit constructor (one is synthesized)
type
  TConfig = class
    property Host: String = 'localhost';
    property Port: Integer = 8080;
    property Retries: Integer = 3;
  end;

var
  c: TConfig;
begin
  c := TConfig.Create;
  if c.Host <> 'localhost' then halt(1);
  if c.Port <> 8080 then halt(2);
  if c.Retries <> 3 then halt(3);
  c.Port := 443;
  if c.Port <> 443 then halt(4);
  c.Free;
end.
