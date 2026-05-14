program tuple_multi_assign_01;

{$mode unleashed}

function GetPair: (Integer, Integer);
begin
  Result := (1, 2);
end;

var
  x, y: Integer;

begin
  (x, y) := GetPair;
  if x <> 1 then halt(1);
  if y <> 2 then halt(2);
end.
