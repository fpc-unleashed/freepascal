program composable_records_perfield_in_packed_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: Word align 2;
    c: Byte;
  end;

begin
  { packed makes default alignment 1; align 2 on b forces it to even offset.
    a=1 byte at offset 0, b=2 bytes at offset 2 (1 pad), c=1 byte at offset 4 }
  if SizeOf(TRec) <> 5 then halt(1);
end.
