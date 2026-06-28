program auto_properties_soft_keyword_identifier_11;

{$mode objfpc}

// readonly and writeonly are soft keywords; without the modeswitch they stay
// ordinary identifiers, so existing code keeps compiling
var
  readonly: Integer;
  writeonly: String;
begin
  readonly := 5;
  writeonly := 'ok';
  if readonly <> 5 then halt(1);
  if writeonly <> 'ok' then halt(2);
end.
