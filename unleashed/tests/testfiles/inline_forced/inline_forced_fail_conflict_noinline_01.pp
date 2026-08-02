{ %FAIL }
program inline_forced_fail_conflict_noinline_01;
{$mode unleashed}

function F(x: Integer): Integer; inline; noinline;
begin
  Result := x * 2;
end;

begin
  writeln(F(1));
end.
