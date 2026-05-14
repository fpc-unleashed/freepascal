program tuple_field_via_index_on_call_01;

{$mode unleashed}

function Pair: (Integer, Integer);
begin
  Result := (10, 20);
end;

begin
  // can index into tuple result of a call
  if Pair[0] <> 10 then halt(1);
  if Pair[1] <> 20 then halt(2);
end.
