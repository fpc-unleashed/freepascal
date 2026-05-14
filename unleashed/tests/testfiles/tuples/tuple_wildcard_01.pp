program tuple_wildcard_01;

{$mode unleashed}

function GetQuad: (Integer, Integer, Integer, Integer);
begin
  Result := (1, 2, 3, 4);
end;

begin
  var (first, _, _, last) := GetQuad;
  if first <> 1 then halt(1);
  if last  <> 4 then halt(2);
end.
