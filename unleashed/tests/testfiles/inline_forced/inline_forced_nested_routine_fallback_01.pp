program inline_forced_nested_routine_fallback_01;
{$mode unleashed}

// a body declaring a nested routine cannot be inlined (the nested routine
// reads the parent frame), so it falls back to a regular call

function Outer(x: Integer): Integer; inline;

  function Inner(y: Integer): Integer;
  begin
    Result := y * 2;
  end;

begin
  Result := Inner(x) + 1;
end;

begin
  if Outer(5) <> 11 then Halt(1);
  if Outer(0) <> 1 then Halt(2);
end.
