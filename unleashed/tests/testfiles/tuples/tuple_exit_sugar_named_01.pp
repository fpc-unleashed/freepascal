program tuple_exit_sugar_named_01;

{$mode unleashed}

function MakePair: (a, b: Integer);
begin
  Exit(a: 7, b: 8);
end;

begin
  var p := MakePair;
  if p.a <> 7 then halt(1);
  if p.b <> 8 then halt(2);
end.
