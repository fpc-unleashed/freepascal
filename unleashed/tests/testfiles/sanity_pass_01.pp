program sanity_pass_01;

{$mode unleashed}

begin
  var x := 42;
  if x <> 42 then halt(1);
  if x + 1 <> 43 then halt(2);
end.
