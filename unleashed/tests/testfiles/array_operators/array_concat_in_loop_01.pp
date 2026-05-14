program array_concat_in_loop_01;

{$mode unleashed}

begin
  var acc: array of Integer := nil;
  for var i := 1 to 5 do
    acc := acc + [i * i];
  if Length(acc) <> 5 then halt(1);
  if acc[0] <> 1  then halt(2);
  if acc[4] <> 25 then halt(3);
end.
