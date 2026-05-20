{ %FAIL }
program composable_records_fail_dup_embed_first_01;

{$mode unleashed}

type
  TInner = record a: Byte; end;
  TRec = record
    embed TInner;
    a: LongInt;        { 'a' already brought in by embed }
  end;
begin
end.
