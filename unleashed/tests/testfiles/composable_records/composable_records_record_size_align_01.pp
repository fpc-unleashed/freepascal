program composable_records_record_size_align_01;

{$mode unleashed}

type
  TRec = record size 64 align 64    { typical cache-line guard }
    a: LongInt;
  end;

begin
  if SizeOf(TRec) <> 64 then halt(1);
  if AlignOf(TRec) <> 64 then halt(2);
end.
