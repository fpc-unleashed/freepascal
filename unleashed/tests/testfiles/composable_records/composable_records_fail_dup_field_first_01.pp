{ %FAIL }
program composable_records_fail_dup_field_first_01;

{$mode unleashed}

type
  TInner = record a: Byte; end;
  TRec = record
    a: LongInt;
    embed TInner;      { embed brings a colliding 'a' }
  end;
begin
end.
