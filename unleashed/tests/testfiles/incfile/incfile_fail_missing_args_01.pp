{ %FAIL }
program incfile_fail_missing_args_01;
{$mode unleashed}

// directive without any args - should error out
{$incfile}
begin
end.
