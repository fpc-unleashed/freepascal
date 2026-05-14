program composable_records_intrinsic_offsetof_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongInt;
    c: Byte;
  end;

begin
  if OffsetOf(TRec.a) <> 0 then halt(1);
  if OffsetOf(TRec.b) <> 1 then halt(2);
  if OffsetOf(TRec.c) <> 5 then halt(3);
end.
