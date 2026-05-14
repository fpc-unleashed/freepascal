program multi_var_init_evaluated_once_01;

{$mode unleashed}

var
  call_count: Integer = 0;

function NextValue: Integer;
begin
  Inc(call_count);
  Result := 42;
end;

begin
  // initializer evaluated once, value assigned to each var
  var a, b, c := NextValue;
  if a <> 42 then halt(1);
  if b <> 42 then halt(2);
  if c <> 42 then halt(3);
  if call_count <> 1 then halt(4);
end.
