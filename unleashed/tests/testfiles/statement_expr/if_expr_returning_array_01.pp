program if_expr_returning_array_01;

{$mode unleashed}

begin
  for var positive := false to true do
  begin
    var arr := if positive then [1, 2, 3] else [-1, -2, -3];
    if Length(arr) <> 3 then halt(1);
    if positive and (arr[0] <> 1)  then halt(2);
    if (not positive) and (arr[0] <> -1) then halt(3);
  end;
end.
