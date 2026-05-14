program compound_with_function_call_rhs_01;

{$mode unleashed}

var
  call_count: Integer = 0;

function NextDelta: Integer;
begin
  Inc(call_count);
  Result := 5;
end;

begin
  var n := 100;
  n += NextDelta;
  if n <> 105 then halt(1);
  if call_count <> 1 then halt(2);

  n -= NextDelta;
  if n <> 100 then halt(3);
  if call_count <> 2 then halt(4);
end.
