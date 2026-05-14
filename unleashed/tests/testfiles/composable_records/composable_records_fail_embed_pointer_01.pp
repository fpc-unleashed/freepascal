{ %FAIL }
program composable_records_fail_embed_pointer_01;

{$mode unleashed}

type
  PInteger = ^Integer;
  TRec = record
    embed PInteger;   { pointer - no fields to flatten }
  end;
begin
end.
