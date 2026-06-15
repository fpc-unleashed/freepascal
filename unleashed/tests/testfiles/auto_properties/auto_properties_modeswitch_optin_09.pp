program auto_properties_modeswitch_optin_09;

{$mode objfpc}
{$modeswitch autoproperties}

// the feature is opt-in outside unleashed mode via the modeswitch
type
  TThing = class
    property Value: Integer;
  end;

var
  t: TThing;
begin
  t := TThing.Create;
  t.Value := 11;
  if t.Value <> 11 then halt(1);
  t.Free;
end.
