program composable_records_record_size_01;

{$mode unleashed}

type
  TRec = record size 16
    a: LongInt;
  end;

begin
  if SizeOf(TRec) <> 16 then halt(1);
end.
