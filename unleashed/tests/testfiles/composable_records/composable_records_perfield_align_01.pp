program composable_records_perfield_align_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongInt align 4;       { force 4-byte alignment inside packed }
  end;

begin
  if (PtrUInt(@TRec(nil^).b) mod 4) <> 0 then halt(1);
end.
