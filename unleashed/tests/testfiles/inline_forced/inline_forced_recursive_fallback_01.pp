program inline_forced_recursive_fallback_01;
{$mode unleashed}

// expanding a recursive routine at every call site never terminates, so the
// routine falls back to a regular call (with a warning)

function Fact(n: Integer): Integer; inline;
begin
  if n <= 1 then
    Result := 1
  else
    Result := n * Fact(n - 1);
end;

begin
  if Fact(5) <> 120 then Halt(1);
  if Fact(1) <> 1 then Halt(2);
end.
