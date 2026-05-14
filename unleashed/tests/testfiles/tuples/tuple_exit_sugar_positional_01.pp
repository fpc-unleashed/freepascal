program tuple_exit_sugar_positional_01;

{$mode unleashed}

function MakePair: (Integer, Integer);
begin
  Exit(10, 20);
end;

begin
  var p := MakePair;
  if p._1 <> 10 then halt(1);
  if p._2 <> 20 then halt(2);
end.
