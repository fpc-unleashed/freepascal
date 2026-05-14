program inline_vars_init_from_function_01;

{$mode unleashed}

function GetInt: Integer;
begin
  Result := 42;
end;

function GetStr: String;
begin
  Result := 'computed';
end;

begin
  var n := GetInt;
  if n <> 42 then halt(1);
  var s := GetStr;
  if s <> 'computed' then halt(2);
end.
