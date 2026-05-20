{ %FAIL }
program composable_records_fail_union_exceeds_size_01;

{$mode unleashed}

type
  TRec = record
    union size 2
      a: LongInt;     { 4 bytes > declared size 2 }
    end;
  end;
begin
end.
