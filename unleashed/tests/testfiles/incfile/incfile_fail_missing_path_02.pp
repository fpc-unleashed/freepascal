{ %FAIL }
program incfile_fail_missing_path_02;
{$mode unleashed}

// directive with var name but no file path - should error out
{$incfile foo}
begin
end.
