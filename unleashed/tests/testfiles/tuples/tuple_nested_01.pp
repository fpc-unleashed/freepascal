program tuple_nested_01;

{$mode unleashed}

begin
  var n: (Integer, (String, Integer));
  n := (5, ('label', 42));
  if n._1 <> 5 then halt(1);
  if n._2._1 <> 'label' then halt(2);
  if n._2._2 <> 42 then halt(3);
end.
