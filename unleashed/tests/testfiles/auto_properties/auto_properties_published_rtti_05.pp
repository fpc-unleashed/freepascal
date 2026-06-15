program auto_properties_published_rtti_05;

{$mode unleashed}
uses Classes, TypInfo;

// a published auto-property binds read/write straight to the field, which is
// RTTI-complete: Get/SetStrProp and Get/SetOrdProp all work
type
  TConfig = class(TPersistent)
  published
    property Host: String;
    property Port: Integer;
  end;

var
  c: TConfig;
begin
  c := TConfig.Create;
  c.Host := 'localhost';
  c.Port := 8080;
  if GetStrProp(c, 'Host') <> 'localhost' then halt(1);
  if GetOrdProp(c, 'Port') <> 8080 then halt(2);
  SetOrdProp(c, 'Port', 443);
  if c.Port <> 443 then halt(3);
  SetStrProp(c, 'Host', 'example.org');
  if c.Host <> 'example.org' then halt(4);
  c.Free;
end.
