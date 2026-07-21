program out_var_dynarray_01;
{$mode unleashed}

procedure fill(out a: TArray<integer>);
begin
  a := [7, 8, 9];
end;

begin
  fill(var arr);
  if Length(arr) <> 3 then Halt(1);
  if arr[2] <> 9 then Halt(2);
end.
