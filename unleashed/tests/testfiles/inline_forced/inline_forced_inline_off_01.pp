program inline_forced_inline_off_01;
{$mode unleashed}
{$inline off}

// $inline off degrades the routines back to stock hints, so nothing is
// expanded and constructs that the forced regime warns about (recursion
// here) compile silently

function Twice(x: Integer): Integer; inline;
begin
  Result := x * 2;
end;

function Fact(n: Integer): Integer; inline;
begin
  if n <= 1 then
    Result := 1
  else
    Result := n * Fact(n - 1);
end;

begin
  if Twice(21) <> 42 then Halt(1);
  if Fact(5) <> 120 then Halt(2);
end.
