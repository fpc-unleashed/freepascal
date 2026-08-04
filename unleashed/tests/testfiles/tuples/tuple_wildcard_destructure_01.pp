{$mode unleashed}
{ test wildcard _ in destructuring }
program tuple_wildcard_destructure_01;

function Triple: (Integer, Integer, Integer);
begin
  Result := (10, 20, 30);
end;

function Pair: (Integer, String);
begin
  Result := (42, 'hello');
end;

var
  a: Integer;
begin
  { skip middle element }
  var (x, _, z) := Triple;
  if (x <> 10) or (z <> 30) then halt(1);

  { skip second element }
  var (n, _) := Pair;
  if n <> 42 then halt(2);

  { multi-assign with wildcard }
  a := 0;
  (a, _) := Pair;
  if a <> 42 then halt(3);

  { skip first and last }
  var (_, q, _) := Triple;
  if q <> 20 then halt(4);

  writeln('ok');
end.
