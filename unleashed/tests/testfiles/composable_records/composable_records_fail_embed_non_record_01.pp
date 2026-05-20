{ %FAIL }
program composable_records_fail_embed_non_record_01;

{$mode unleashed}

type
  TRec = record
    embed LongInt;     { embed target must be a record/object type }
  end;
begin
end.
