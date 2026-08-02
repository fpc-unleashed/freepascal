program inline_forced_forward_nested_caller_01;
{$mode unleashed}

// the pending call sits in a nested routine of the deferred caller

function Late(x: Integer): Integer; inline; forward;

function Outer(x: Integer): Integer;

  function Inner(y: Integer): Integer;
  begin
    Result := Late(y) * 2;
  end;

begin
  Result := Inner(x) + 1;
end;

function Late(x: Integer): Integer;
begin
  Result := x + 5;
end;

begin
  if Outer(10) <> 31 then Halt(1);
  if Outer(0) <> 11 then Halt(2);
end.
