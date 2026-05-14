program array_concat_chain_01;

{$mode unleashed}

begin
  var a: array of Integer := [1];
  var b: array of Integer := [2, 3];
  var c: array of Integer := [4, 5, 6];
  var d: array of Integer := [7];

  var all := a + b + c + d;
  if Length(all) <> 7 then halt(1);
  if all[0] <> 1 then halt(2);
  if all[6] <> 7 then halt(3);
  // sum
  var s := 0;
  for var x in all do s := s + x;
  if s <> 28 then halt(4);
end.
