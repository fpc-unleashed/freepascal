program tuple_generic_make_pair_01;

{$mode unleashed}

generic function MakePair<A, B>(x: A; y: B): (A, B);
begin
  Result._1 := x;
  Result._2 := y;
end;

begin
  var p := specialize MakePair<Integer, String>(7, 'seven');
  if p._1 <> 7       then halt(1);
  if p._2 <> 'seven' then halt(2);
end.
