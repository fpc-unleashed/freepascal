{ %FAIL }
program embedbytes_fail_missing_args_02;
{$mode unleashed}

// no arguments - should error out
{$embedbytes}
begin
end.
