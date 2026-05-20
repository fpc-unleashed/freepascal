program composable_records_wild_alignof_field_with_align_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: Byte align 8;
  end;

begin
  if AlignOf(TRec.a) <> 1 then halt(1);
  if AlignOf(TRec.b) <> 8 then halt(2);
end.
