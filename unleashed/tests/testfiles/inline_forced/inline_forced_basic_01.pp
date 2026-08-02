program inline_forced_basic_01;
{$mode unleashed}

function Add3(a, b, c: Integer): Integer; inline;
begin
  Result := a + b + c;
end;

begin
  if Add3(1, 2, 3) <> 6 then Halt(1);
  if Add3(10, 20, 30) <> 60 then Halt(2);
end.
