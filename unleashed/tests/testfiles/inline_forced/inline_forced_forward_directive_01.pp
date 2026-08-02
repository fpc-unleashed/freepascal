program inline_forced_forward_directive_01;
{$mode unleashed}

// the forward directive combines with inline (rejected outside
// unleashed mode); the call site precedes both bodies

function Add5(x: Integer): Integer; inline; forward;

function Chain(x: Integer): Integer;
begin
  Result := Add5(x) * 10;
end;

function Add5(x: Integer): Integer;
begin
  Result := x + 5;
end;

begin
  if Chain(1) <> 60 then Halt(1);
  if Chain(-5) <> 0 then Halt(2);
end.
