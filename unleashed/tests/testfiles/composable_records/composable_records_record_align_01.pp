program composable_records_record_align_01;

{$mode unleashed}

type
  TRec = record align 32
    a: Byte;
  end;

begin
  if AlignOf(TRec) <> 32 then halt(1);
end.
