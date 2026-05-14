program tuple_returned_in_destructure_01;

{$mode unleashed}

function DivMod(a, b: Integer): (q, r: Integer);
begin
  Result := (q: a div b, r: a mod b);
end;

begin
  var (q, r) := DivMod(17, 5);
  if q <> 3 then halt(1);
  if r <> 2 then halt(2);

  var (x, y) := DivMod(100, 7);
  if x <> 14 then halt(3);
  if y <> 2  then halt(4);
end.
