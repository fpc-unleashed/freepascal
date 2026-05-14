{ %FAIL }
program composable_records_fail_record_exceeds_size_01;

{$mode unleashed}

type
  TRec = record size 2
    a, b: LongInt;        { 8 bytes total, exceeds declared 2 }
  end;
begin
end.
