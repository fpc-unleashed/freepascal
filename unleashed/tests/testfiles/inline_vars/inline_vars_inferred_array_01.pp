program inline_vars_inferred_array_01;

{$mode unleashed}

begin
  var arr := [1, 2, 3];
  if Length(arr) <> 3 then halt(1);
  if arr[0] <> 1 then halt(2);
  if arr[1] <> 2 then halt(3);
  if arr[2] <> 3 then halt(4);
end.
