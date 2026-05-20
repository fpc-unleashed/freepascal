program composable_records_intrinsic_field_alignof_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongInt align 8;
  end;

begin
  if AlignOf(TRec.b) <> 8 then halt(1);
end.
