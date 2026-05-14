program tuple_literal_positional_01;

{$mode unleashed}

function Pair: (Integer, Integer);
begin
  Result := (10, 20);
end;

begin
  var p := Pair;
  if p._1 <> 10 then halt(1);
  if p._2 <> 20 then halt(2);
end.
