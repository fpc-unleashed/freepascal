program tuple_literal_named_01;

{$mode unleashed}

function MakePoint: (x, y: Integer);
begin
  Result := (x: 10, y: 20);
end;

function MakeReversed: (x, y: Integer);
begin
  // named literals can be in any order
  Result := (y: 99, x: 7);
end;

begin
  var p := MakePoint;
  if p.x <> 10 then halt(1);
  if p.y <> 20 then halt(2);

  var q := MakeReversed;
  if q.x <> 7  then halt(3);
  if q.y <> 99 then halt(4);
end.
