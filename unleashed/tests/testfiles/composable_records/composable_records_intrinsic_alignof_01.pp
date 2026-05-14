program composable_records_intrinsic_alignof_01;

{$mode unleashed}

type
  TRec = record align 16
    v: LongInt;
  end;

begin
  if AlignOf(TRec) <> 16 then halt(1);
end.
