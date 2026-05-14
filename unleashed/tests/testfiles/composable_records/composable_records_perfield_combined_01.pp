program composable_records_perfield_combined_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongInt align 8 size 16;     { aligned to 8, slot widened to 16 }
    c: Byte;
  end;

begin
  if SizeOf(TRec) <> 25 then halt(1);
end.
