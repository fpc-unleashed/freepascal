program tuple_three_fields_01;

{$mode unleashed}

function GetVec3: (x, y, z: Double);
begin
  Result := (x: 1.0, y: 2.5, z: -3.0);
end;

begin
  var v := GetVec3;
  if v.x   <> 1.0 then halt(1);
  if v.y   <> 2.5 then halt(2);
  if v.z   <> -3.0 then halt(3);
  if v[0]  <> 1.0 then halt(4);
end.
