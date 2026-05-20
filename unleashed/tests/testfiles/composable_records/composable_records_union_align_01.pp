program composable_records_union_align_01;

{$mode unleashed}

type
  TRec = record
    leader: Byte;
    union align 8 size 8
      v: LongInt;
    end;
  end;

begin
  { align 8 bumps the union past the leader byte to offset 8;
    plus 8 bytes of union storage = 16 bytes total }
  if SizeOf(TRec) <> 16 then halt(1);
end.
