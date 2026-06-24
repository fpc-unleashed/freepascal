{ %FAIL }
program embedstr_fail_missing_args_01;
{$mode unleashed}

// no arguments - should error out
{$embedstr}
begin
end.
