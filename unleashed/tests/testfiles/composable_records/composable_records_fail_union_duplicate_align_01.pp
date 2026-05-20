{ %FAIL }
program composable_records_fail_union_duplicate_align_01;

{$mode unleashed}

type
  TRec = record
    union align 4 align 8
      a: LongInt;
    end;
  end;
begin
end.
