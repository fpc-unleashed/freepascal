program tuple_destructure_inline_01;

{$mode unleashed}

function GetPair: (Integer, Integer);
begin
  Result := (10, 20);
end;

begin
  var (a, b) := GetPair;
  if a <> 10 then halt(1);
  if b <> 20 then halt(2);
end.
