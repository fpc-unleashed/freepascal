{ %FAIL }
program composable_records_fail_embed_string_01;

{$mode unleashed}

type
  TRec = record
    embed AnsiString;   { string is not a record type }
  end;
begin
end.
