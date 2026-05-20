{ %FAIL }
program composable_records_fail_dup_union_variant_01;

{$mode unleashed}

type
  TInner = record a: Byte; end;
  TRec = packed record
    embed TInner;
    union of Byte size 4
      a: LongInt;      { colliding with embed's 'a' }
      b: array[0..3] of Byte;
    end;
  end;
begin
end.
