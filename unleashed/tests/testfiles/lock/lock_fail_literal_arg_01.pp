{ %FAIL }
program lock_fail_literal_arg_01;
{$mode unleashed}

// the argument to `lock(...)` must be a variable reference -
// expressions, literals and call results are rejected
var
  counter: Integer;
begin
  lock(1 + 2) do Inc(counter);
end.
