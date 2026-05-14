program composable_records_union_bitalign_01;

{$mode unleashed}

type
  TRec = record
    leader: Byte;
    union bitalign 64 size 8
      v: LongInt;
    end;
  end;

begin
  { bitalign 64 -> ceil(64/8) = 8 bytes alignment, same effect as align 8 }
  if SizeOf(TRec) <> 16 then halt(1);
end.
