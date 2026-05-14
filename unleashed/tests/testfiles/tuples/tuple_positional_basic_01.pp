program tuple_positional_basic_01;

{$mode unleashed}

var
  p: (Integer, String);

begin
  p._1 := 42;
  p._2 := 'hello';
  if p._1 <> 42 then halt(1);
  if p._2 <> 'hello' then halt(2);
  if p[0] <> 42 then halt(3);
  if p[1] <> 'hello' then halt(4);
end.
