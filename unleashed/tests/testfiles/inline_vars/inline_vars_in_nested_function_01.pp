program inline_vars_in_nested_function_01;

{$mode unleashed}

function Outer: Integer;

  function Inner(n: Integer): Integer;
  begin
    var doubled := n * 2;
    Result := doubled + 1;
  end;

begin
  var local_n := 5;
  Result := Inner(local_n);
end;

begin
  if Outer <> 11 then halt(1);
end.
