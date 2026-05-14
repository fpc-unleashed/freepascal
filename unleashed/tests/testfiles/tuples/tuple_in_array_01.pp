program tuple_in_array_01;

{$mode unleashed}

begin
  var pairs: array of (Integer, Integer);
  pairs := [(1, 2), (3, 4), (5, 6)];
  if Length(pairs) <> 3 then halt(1);
  if pairs[0]._1 <> 1 then halt(2);
  if pairs[1]._2 <> 4 then halt(3);
  if pairs[2]._1 <> 5 then halt(4);
end.
