program if_expr_in_array_index_01;

{$mode unleashed}

begin
  var arr: array of Integer := [10, 20, 30, 40];
  var pick_first := true;
  var v := arr[if pick_first then 0 else High(arr)];
  if v <> 10 then halt(1);
  pick_first := false;
  v := arr[if pick_first then 0 else High(arr)];
  if v <> 40 then halt(2);
end.
