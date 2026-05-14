{ %FAIL }
program composable_records_fail_union_of_after_size_01;

{$mode unleashed}

type
  TRec = packed record
    union size 4 of Byte
      a: LongInt;
    end;
  end;
begin
end.
