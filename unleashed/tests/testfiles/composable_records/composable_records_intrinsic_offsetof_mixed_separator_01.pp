program composable_records_intrinsic_offsetof_mixed_separator_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongInt;
  end;

begin
  { mixing Pascal-style and C-style separators in the same source is allowed }
  if OffsetOf(TRec.a) + OffsetOf(TRec, b) <> 1 then halt(1);
end.
