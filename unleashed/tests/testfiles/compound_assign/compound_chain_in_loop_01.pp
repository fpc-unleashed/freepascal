program compound_chain_in_loop_01;

{$mode unleashed}

begin
  var n := 1;
  for var i := 1 to 10 do
    n *= 2;
  if n <> 1024 then halt(1);

  n := 1024;
  for var i := 1 to 10 do
    n shr= 1;
  if n <> 1 then halt(2);
end.
