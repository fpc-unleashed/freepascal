{ %FAIL }
program embed_fail_file_not_found_03;
{$mode unleashed}

// path resolves to nothing - fatal "Cannot open include file"
{$embedstr foo 'this_file_does_not_exist_anywhere.bin'}
begin
end.
